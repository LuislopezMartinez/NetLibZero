ArrayList<ClientController>clients = new ArrayList<ClientController>();
//---------------------------------------------------------------------
class ClientController extends sprite {

    int st = 0;
    WebSocket sock;

    public ClientController( WebSocket sock ) {
        this.sock = sock;
    }
    //------------
    void initialize() {
    }
    //------------
    void finalize() {
    }
    //------------
    void frame() {
        switch(this.st) {
        case 0:
            //..
            break;
        case 10:

            break;
        }
    }
    //------------
    //------------
}
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
