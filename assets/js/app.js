import "phoenix_html"

/* Disable sockets for now */
// import socket from "./socket"

const initForm = () => {
  'use strict'

  // Routes where this form should be initialized
  let supportedRoutes = ['/', '/onboarding', '/alerts/new']
  let { pathname } = window.location

  // Disable form activation for other pages
  if (!supportedRoutes.includes(pathname)) return

  // Helpers
  const $ = el => document.querySelector(el)
  const $$ = els => document.querySelectorAll(els)

  const hide = el => $(el).classList.add('d-none')
  const show = el => $(el).classList.remove('d-none')

  const activateSelect = id => $$('.threshold-select')
    .forEach(el => {
      if (el.id == id) {
        el.name = "alert[threshold]"
        el.classList.remove('d-none')
      } else {
        el.name = ''
        el.classList.add('d-none')
      }
    })

  const selectBtc = () => {
    hide('#tokens')
    activateSelect('btc-select')
  }

  const selectEth = () => {
    hide('#tokens')
    show('#exchanges')
    activateSelect('eth-select')
  }

  const selectTokens = () => {
    show('#tokens')
    show('#exchanges')
    activateSelect('token-select')
  }

  const selectAlertType = type => {
    fetchWallets(type)
    switch (type) {
      case "btc":   return selectBtc()
      case "eth":   return selectEth()
      case "erc20": return selectTokens()
    }
  }

  const addOptionEl = (root, node, text) => {
    let option_text = document.createTextNode("All")
    node.appendChild(option_text)
    root.appendChild(node)
  }

  const addOption = (root, node, text) => {
    let option_text = document.createTextNode(text)
    node.appendChild(option_text)
    root.appendChild(node)
  }

  const fetchWallets = type => {
    let link = `/wallets?type=${type}`
    fetch(link, { headers: { "Content-Type": "application/json; charset=utf-8" }})
      .then(res => res.json()) // parse response as JSON (can be res.text() for plain response)
      .then(response => {

        let exchange_select = document.getElementById("exchange-select")
        while (exchange_select.firstChild) {
          exchange_select.removeChild(exchange_select.firstChild)
        }
        let default_option = document.createElement("option")
        addOption(exchange_select, default_option, "All")
        for (let i = 0; i < response.length; i++) {
          let option = document.createElement("option")
          addOption(exchange_select, option, response[i].name)
        }
        return response
      })
      .catch(err => {
        console.log(err)
        alert("sorry, there are no results for your search")
    });
  }

  $$('.switch-label').forEach(el =>
    el.addEventListener('click', ({ target }) => selectAlertType(target.id))
  )
  $('#alert_type_btc').checked = true
}

$('.btn-toggle').click(function(e) {
  $(this).find('.btn').toggleClass('active');
  let plan = $(e.target).data("plan");
  if (plan === "monthly") {
    $(".billing_type").html("Billed monthly - Cancel anytime");
    $("#monthly-plan").removeClass('d-none');
    $("#yearly-plan").addClass('d-none');
    $("#plan-price").html("$24.99* <span>/ Month</span>");
  } else {
   $("#plan-price").html("$19.99* <span>/ Month</span>");
    $(".billing_type").html("Billed anually - Cancel anytime");
    $("#monthly-plan").addClass('d-none');
    $("#yearly-plan").removeClass('d-none');
  }

  if ($(this).find('.btn-primary').length>0) {
  	$(this).find('.btn').toggleClass('btn-primary');
  }
  $(this).find('.btn').toggleClass('btn-default');
});

document.addEventListener("DOMContentLoaded", () => initForm())
