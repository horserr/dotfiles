#!/usr/bin/env python3
"""ntfy-approvals smoke tests — no external network required.

A local HTTP server stands in for ntfy, so publishing is exercised end to end
without touching the internet.

usage: python3 tests/smoke.py [-v]
"""

from __future__ import annotations

import http.server
import importlib.util
import json
import os
import socketserver
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "scripts" / "ntfy_approvals.py"

sys.path.insert(0, str(ROOT / "scripts"))
import qrgen


class Recorder(http.server.BaseHTTPRequestHandler):
    payloads: list[dict] = []

    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0") or 0)
        body = self.rfile.read(length) if length else b"{}"
        try:
            Recorder.payloads.append(json.loads(body))
        except json.JSONDecodeError:
            Recorder.payloads.append({"raw": body.decode("utf-8", "replace")})
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b"{}")

    def log_message(self, *args):  # silence request logging
        pass


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def wait_for(predicate, timeout=10.0, interval=0.05):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        value = predicate()
        if value:
            return value
        time.sleep(interval)
    return None


class Base(unittest.TestCase):
    server: Server

    @classmethod
    def setUpClass(cls):
        cls.server = Server(("127.0.0.1", 0), Recorder)
        cls.port = cls.server.server_address[1]
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def setUp(self):
        Recorder.payloads.clear()
        self.tmp = tempfile.TemporaryDirectory()
        self.state = Path(self.tmp.name) / "state"
        self.state.mkdir(parents=True)
        self.env = dict(os.environ)
        self.env.update(
            {
                "NTFY_APPROVALS_STATE_DIR": str(self.state),
                "NTFY_APPROVALS_BASE": f"http://127.0.0.1:{self.port}",
                "NTFY_APPROVALS_DEBUG": "1",
                "NTFY_APPROVALS_TOKEN": "",
            }
        )
        self.env.pop("NOTIFY_TOPIC", None)
        self.env.pop("CONTROL_TOPIC", None)

    def tearDown(self):
        self.tmp.cleanup()

    # helpers ---------------------------------------------------------------
    def run_cli(self, *args, payload=None, env=None, timeout=40):
        merged = dict(self.env)
        merged.update(env or {})
        return subprocess.run(
            [sys.executable, str(SCRIPT), *args],
            input=json.dumps(payload) if payload is not None else "",
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            env=merged,
            timeout=timeout,
        )

    def single_json(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = [line for line in result.stdout.splitlines() if line.strip()]
        self.assertEqual(len(lines), 1, f"expected one line, got {lines!r}")
        return json.loads(lines[0])

    def config_topics(self):
        text = (self.state / "ntfy-approvals.env").read_text(encoding="utf-8")
        values = {}
        for line in text.splitlines():
            if "=" in line and not line.startswith("#"):
                key, _, value = line.partition("=")
                values[key.strip()] = value.strip()
        return values

    def start_approve(self, payload, env=None):
        payload_file = Path(self.tmp.name) / "payload.json"
        payload_file.write_text(json.dumps(payload), encoding="utf-8")
        merged = dict(self.env)
        merged.update(env or {})
        return subprocess.Popen(
            [sys.executable, str(SCRIPT), "approve"],
            stdin=payload_file.open(encoding="utf-8"),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
            env=merged,
        )

    def approve_request_id(self):
        def finder():
            for payload in list(Recorder.payloads):
                for action in payload.get("actions") or []:
                    body = str(action.get("body", ""))
                    if body.startswith("allow "):
                        return body.split(" ", 1)[1].strip()
            return None

        return wait_for(finder, timeout=15)


class NotifyTests(Base):
    def test_single_json_object(self):
        payload = {
            "hook_event_name": "Notification",
            "notification_type": "idle_prompt",
            "cwd": "/srv/app",
        }
        obj = self.single_json(self.run_cli("notify", payload=payload))
        self.assertEqual(list(obj), ["terminalSequence"])
        self.assertIn("\x1b]9;", obj["terminalSequence"])
        self.assertTrue(obj["terminalSequence"].startswith("\a"))

    def test_pushes_to_ntfy(self):
        payload = {
            "hook_event_name": "Notification",
            "notification_type": "idle_prompt",
            "cwd": "/srv/app",
        }
        self.run_cli("notify", payload=payload)
        recorded = wait_for(lambda: Recorder.payloads, timeout=10)
        self.assertIsNotNone(recorded, "no ntfy publish recorded")
        assert recorded is not None
        self.assertEqual(recorded[0]["topic"], self.config_topics()["NOTIFY_TOPIC"])
        self.assertIn("app:", recorded[0]["message"])

    def test_stop_silent_by_default(self):
        result = self.run_cli(
            "notify", payload={"hook_event_name": "Stop", "cwd": "/srv/app"}
        )
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), "")

    def test_stop_opt_in(self):
        result = self.run_cli(
            "notify",
            payload={"hook_event_name": "Stop", "cwd": "/srv/app"},
            env={"NTFY_APPROVALS_ON_DONE": "1"},
        )
        obj = self.single_json(result)
        self.assertIn("terminalSequence", obj)

    def test_push_disabled_still_alerts_terminal(self):
        result = self.run_cli(
            "notify",
            payload={
                "hook_event_name": "Notification",
                "notification_type": "idle_prompt",
                "cwd": "/srv/app",
            },
            env={"NTFY_APPROVALS_PUSH": "0"},
        )
        obj = self.single_json(result)
        self.assertIn("terminalSequence", obj)
        time.sleep(0.3)
        self.assertEqual(Recorder.payloads, [])

    def test_stopfailure(self):
        payload = {
            "hook_event_name": "StopFailure",
            "error": "rate_limit",
            "cwd": "/srv/app",
        }
        obj = self.single_json(self.run_cli("notify", payload=payload))
        self.assertIn("rate_limit", obj["terminalSequence"])


class TopicTests(Base):
    def test_topics_generated_once_and_stable(self):
        first = self.run_cli("control", "topic")
        second = self.run_cli("control", "topic")
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(first.stdout, second.stdout)
        topics = self.config_topics()
        self.assertIn("NOTIFY_TOPIC", topics)
        self.assertIn("CONTROL_TOPIC", topics)
        self.assertNotEqual(topics["NOTIFY_TOPIC"], topics["CONTROL_TOPIC"])
        self.assertIn(
            f"ntfy://127.0.0.1:{self.port}/{topics['NOTIFY_TOPIC']}", first.stdout
        )

    def test_send_uses_control_topic(self):
        self.run_cli("control", "init")
        topics = self.config_topics()
        result = self.run_cli("control", "send", "hello")
        self.assertEqual(result.returncode, 0, result.stderr)
        recorded = wait_for(lambda: Recorder.payloads, timeout=10)
        self.assertIsNotNone(recorded)
        assert recorded is not None
        self.assertEqual(recorded[0]["topic"], topics["CONTROL_TOPIC"])
        self.assertEqual(recorded[0]["message"], "hello")

    def test_status_runs(self):
        result = self.run_cli("control", "status")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("relay", result.stdout)

    def test_topic_prints_qr(self):
        result = self.run_cli("control", "topic")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any(ch in result.stdout for ch in "▀▄█"))
        off = self.run_cli("control", "topic", env={"NTFY_APPROVALS_QR": "0"})
        self.assertFalse(any(ch in off.stdout for ch in "▀▄█"))


class ApproveTests(Base):
    PAYLOAD = {
        "hook_event_name": "PermissionRequest",
        "tool_name": "Bash",
        "tool_input": {"command": "rm -rf node_modules"},
        "cwd": "/srv/app",
    }

    def decide(self, request_id, action):
        directory = self.state / "control"
        directory.mkdir(parents=True, exist_ok=True)
        (directory / f"{request_id}.json").write_text(
            json.dumps({"action": action}), encoding="utf-8"
        )

    def test_allow(self):
        proc = self.start_approve(
            self.PAYLOAD, {"NTFY_APPROVALS_APPROVE_TIMEOUT": "20"}
        )
        request_id = self.approve_request_id()
        self.assertIsNotNone(request_id, "approve never published an action")
        recorded = Recorder.payloads[-1]
        self.assertEqual(recorded["priority"], 5)
        self.assertEqual(
            [a["label"] for a in recorded["actions"]], ["✅ Allow", "⛔ Deny"]
        )
        self.assertEqual(recorded["actions"][0]["method"], "POST")
        self.assertTrue(recorded["actions"][0]["clear"])
        assert request_id is not None
        self.decide(request_id, "allow")
        out, err = proc.communicate(timeout=40)
        self.assertEqual(proc.returncode, 0, err)
        obj = json.loads(out.strip().splitlines()[0])
        self.assertEqual(obj["hookSpecificOutput"]["decision"]["behavior"], "allow")
        self.assertEqual(
            obj["hookSpecificOutput"]["hookEventName"], "PermissionRequest"
        )
        self.assertFalse(
            (self.state / "control" / f"{request_id}.json").exists(),
            "decision file not consumed",
        )

    def test_deny(self):
        proc = self.start_approve(
            self.PAYLOAD, {"NTFY_APPROVALS_APPROVE_TIMEOUT": "20"}
        )
        request_id = self.approve_request_id()
        self.assertIsNotNone(request_id)
        assert request_id is not None
        self.decide(request_id, "deny")
        out, _ = proc.communicate(timeout=40)
        obj = json.loads(out.strip().splitlines()[0])
        self.assertEqual(obj["hookSpecificOutput"]["decision"]["behavior"], "deny")
        self.assertIn("message", obj["hookSpecificOutput"]["decision"])

    def test_timeout_falls_through(self):
        result = self.run_cli(
            "approve", payload=self.PAYLOAD, env={"NTFY_APPROVALS_APPROVE_TIMEOUT": "2"}
        )
        obj = self.single_json(result)
        self.assertIn("terminalSequence", obj)
        self.assertNotIn("hookSpecificOutput", obj)

    def test_zero_timeout_is_non_blocking(self):
        started = time.monotonic()
        result = self.run_cli(
            "approve", payload=self.PAYLOAD, env={"NTFY_APPROVALS_APPROVE_TIMEOUT": "0"}
        )
        obj = self.single_json(result)
        self.assertIn("terminalSequence", obj)
        self.assertLess(time.monotonic() - started, 15)
        self.assertEqual(Recorder.payloads, [], "timeout=0 must not publish")

    def test_approve_disabled(self):
        result = self.run_cli(
            "approve", payload=self.PAYLOAD, env={"NTFY_APPROVALS_APPROVE": "0"}
        )
        obj = self.single_json(result)
        self.assertIn("terminalSequence", obj)
        self.assertEqual(Recorder.payloads, [])


class RelayTests(Base):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        spec = importlib.util.spec_from_file_location("ntfy_approvals", SCRIPT)
        assert spec and spec.loader
        cls.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.module)

    def setUp(self):
        super().setUp()
        # the module reads the environment on every call, so patch this process
        patch = mock.patch.dict(
            os.environ,
            {
                "NTFY_APPROVALS_STATE_DIR": str(self.state),
                "NTFY_APPROVALS_TMUX": "0",
                "NTFY_APPROVALS_DEBUG": "1",
            },
        )
        patch.start()
        self.addCleanup(patch.stop)

    def test_handle_event_writes_decision(self):
        self.assertEqual(self.module.handle_event("not json", "keep"), "keep")
        event = {"event": "message", "id": "m1", "message": "allow 123-abc"}
        self.assertEqual(self.module.handle_event(json.dumps(event), ""), "m1")
        decision = self.state / "control" / "123-abc.json"
        self.assertTrue(decision.is_file())
        self.assertEqual(json.loads(decision.read_text())["action"], "allow")

    def test_handle_event_rejects_bad_request_id(self):
        event = {"event": "message", "id": "m2", "message": "allow ../../etc/passwd"}
        self.module.handle_event(json.dumps(event), "")
        self.assertFalse(
            (self.state / "control" / ".." / ".." / "etc" / "passwd.json").exists()
        )

    def test_handle_event_ignores_text_without_tmux(self):
        event = {"event": "message", "id": "m3", "message": "just a reply"}
        self.module.handle_event(json.dumps(event), "")
        self.assertEqual(
            list((self.state / "control").glob("*.json"))
            if (self.state / "control").is_dir()
            else [],
            [],
        )

    def test_handle_event_skips_non_message_events(self):
        event = {"event": "keepalive"}
        self.assertEqual(self.module.handle_event(json.dumps(event), "m4"), "m4")


class QRTests(unittest.TestCase):
    """Structural checks; byte-level verification lives in crosscheck_segno.py."""

    def test_version_and_size(self):
        cases = [("ab", 1), ("a" * 40, 3), ("a" * 200, 10)]
        for payload, expected_version in cases:
            version, level = qrgen.choose_version(payload.encode())
            self.assertEqual(version, expected_version, payload[:8])
            self.assertIn(level, ("L", "M"))
            self.assertEqual(len(qrgen.make(payload)), 17 + 4 * version)

    def test_finder_patterns(self):
        matrix = qrgen.make("ntfy://example")
        size = len(matrix)
        for top, left in ((0, 0), (0, size - 7), (size - 7, 0)):
            dark = sum(matrix[top + r][left + c] for r in range(7) for c in range(7))
            self.assertEqual(dark, 33)

    def test_deterministic(self):
        self.assertEqual(
            qrgen.make("https://ntfy.sh/x"), qrgen.make("https://ntfy.sh/x")
        )

    def test_oversized_raises(self):
        with self.assertRaises(ValueError):
            qrgen.make("a" * 1000)

    def test_render_colored(self):
        payload = "ntfy://x"
        size = len(qrgen.make(payload))
        lines = qrgen.as_text(payload).splitlines()
        self.assertEqual(len(lines), (size + 5) // 2)
        for line in lines:
            self.assertTrue(line.endswith("\x1b[0m"))
            self.assertIn("\x1b[", line)

    def test_render_plain_is_ansi_free(self):
        payload = "ntfy://x"
        size = len(qrgen.make(payload))
        lines = qrgen.as_text(payload, color=False).splitlines()
        self.assertEqual(len(lines), (size + 5) // 2)
        for line in lines:
            self.assertNotIn("\x1b", line)
            self.assertLessEqual(set(line), set("▀▄█ "))
        self.assertTrue(any("█" in line for line in lines))


if __name__ == "__main__":
    unittest.main(verbosity=2)
