//------------------------------------------------------------
void onNetServerCloseWS(WebSocket s) {
    println("[SERVER] Conection closed.");
    ClientController cliente = null;
    for(int i=0; i<clients.size(); i++){
        if(clients.get(i).sock == s){
            cliente = clients.get(i);
        }
    }
    if(cliente != null){
        clients.remove(cliente);
    }
}
//------------------------------------------------------------
void onNetServerOpenWS(WebSocket s) {
    println("[SERVER] New conection established!");
    ClientController c = new ClientController(s);
    clients.add(c);
}
//--------------------------------------------------------------------
// PUT HERE YOUR NET RCV PARSER CODE----------------------------------
//--------------------------------------------------------------------
void onNetServerMessageWS(WebSocket s, StringList msg) {
}
