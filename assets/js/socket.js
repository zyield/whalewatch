import { Socket } from 'phoenix'
import { handleIncomingTx } from './ws_handlers'

let socket = new Socket('/socket', {params: {token: window.userToken}})
socket.connect()

let channel = socket.channel('stream:transactions', {})
channel.join()
  .receive('ok', resp => { console.log('Joined successfully', resp) })
  .receive('error', resp => { console.log('Unable to join', resp) })

channel.on('incoming_tx', handleIncomingTx)

export default socket
