const truncate = str => len => `${str.substring(0, len)}...`

export const handleIncomingTx = tx => {
  let row = document.createElement('tr')
  row.innerHTML = `
    <td>
      <a class="text-info" href="https://etherscan.io/tx/${tx.transactionHash}" target="_blank">
        ${truncate(tx.transactionHash)(15)}
        </a>
    </td>
    <td>${truncate(tx.from)(15)}</td>
    <td>${truncate(tx.to)(15)}</td>
    <td>${truncate(String(tx.value))(5)}</td>
  `
  document.querySelector('.txs-list tbody').prepend(row)
}
