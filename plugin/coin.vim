if exists('g:loaded_coin')
  finish
endif

if !has('nvim')
  finish 
endif

let g:loaded_coin = 1

command! Coin :lua require('coin').create_coin()<CR>
command! EnableCoin :lua require('coin').enable_coin()<CR>
command! DisableCoin :lua require('coin').disable_coin()<CR>