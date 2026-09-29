function filterTable() {
  // 直接查找包含 <span class="feature"> 的所有 <tr> 行并批量删除
  const featureRows = document.querySelectorAll("table tbody tr span.feature");

  featureRows.forEach((span) => {
    const row = span.closest("tr"); // 找到最近的祖先 <tr> 元素
    if (row) {
      row.remove();
    }
  });
}

function copyFilteredTableToClipboard() {
  const table = document.querySelector("table");
  if (!table) return console.error("未找到 table 元素");

  let csvContent = "";

  // 1. 获取表头（如果有 <thead>）
  const headers = Array.from(table.querySelectorAll("thead th, thead td")).map(
    (cell) => `"${cell.textContent.trim().replace(/"/g, '""')}"`,
  );
  if (headers.length > 0) {
    csvContent += headers.join("\t") + "\n";
  }

  // 2. 获取 tbody 中当前存在的每一行 (<tr>)
  const rows = table.querySelectorAll("tbody tr");
  rows.forEach((row) => {
    const rowData = Array.from(row.querySelectorAll("td, th")).map(
      (cell) =>
        `"${cell.textContent.trim().replace(/\s+/g, " ").replace(/"/g, '""')}"`,
    );
    if (rowData.length > 0) {
      csvContent += rowData.join("\t") + "\n";
    }
  });

  // 3. 复制到剪贴板
  copy(csvContent);
  console.log(
    "✅ 过滤后的表格已成功复制到剪贴板！可以直接粘贴到 Excel 或文本编辑器中。",
  );
}
