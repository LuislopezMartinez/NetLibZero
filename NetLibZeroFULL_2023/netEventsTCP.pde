//------------------------------------------------------------
void onNetServerCloseTCP(ServidorTCP s) {
    println("[SERVER] TCP conection closed.");
    s.close();
}
//------------------------------------------------------------
void onNetServerOpenTCP(ServidorTCP s) {
    println("[SERVER] New TCP conection established!");
}
//--------------------------------------------------------------------
// PUT HERE YOUR NET RCV PARSER CODE----------------------------------
//--------------------------------------------------------------------
void onNetServerMessageTCP(ServidorTCP s, StringList msg) {
    println("[SERVER SAYS]: " + msg);

    // interprete de comandos enviados por la red..
    switch(msg.get(0)) {
    case "":

        break;
    default:
        println("WARNING: TCPnetEvent    [" + msg.get(0) +"]    not implemented!");
        break;
    }
}
//--------------------------------------------------------------------
// PUT HERE YOUR NET RCV PARSER CODE----------------------------------
//--------------------------------------------------------------------
void onNetClientMessageTCP(Client c, StringList msg) {
    println(msg);
}
