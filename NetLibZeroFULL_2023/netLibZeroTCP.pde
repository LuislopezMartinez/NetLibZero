import java.io.*;
import java.net.*;
final char NET_TOK_DATA_TCP = '\n';    // delimitier for datagram tokens..
ServerTCP createServerTCP(int port) {
    ServerTCP s = new ServerTCP(port);
    s.start();
    return s;
}

Client createClientTCP(String ip, int port) {
    return new Client(ip, port);
}

//------------------------------------------------------------
//------------------------------------------------------------
String nombre_servidor = "[SERVIDOR MMO]";
String mensaje_welkome = "Bienvenido a " + nombre_servidor;
//------------------------------------------------------------
class ServerTCP extends Thread {
    ArrayList<ServidorTCP>conections = new ArrayList();
    long timeout_frames = 5*fps;
    int PUERTO;
    ServerTCP(int PUERTO) {
        this.PUERTO = PUERTO;
    }
    void run() {
        Socket servicio = null;

        try {
            ServerSocket servidor = new ServerSocket(PUERTO);
            println(nombre_servidor);
            println("Servidor TCP iniciado en el puerto: " + PUERTO);
            while (true) {
                servicio = servidor.accept();
                DataInputStream flujoDatosEntrada = new DataInputStream(servicio.getInputStream());  //Crea un objeto para recibir mensajes del usuario
                OutputStream escribir = servicio.getOutputStream(); //Objeto para mandar a escribir en el cliente
                DataOutputStream flujoDatosSalida = new DataOutputStream(escribir);  //Aqui se escriben las cosasx|

                ServidorTCP cc = new ServidorTCP(this, servicio, flujoDatosEntrada, flujoDatosSalida);  //Parametros, la conexion , y los objetos de escritura/lectura
                delay(10);    // CHECK NEW CONECTIONS EVERY 10 ms..
            }
        }
        catch(Exception e) {
            e.printStackTrace();
        }
    }
    void setTimeout(int seconds) {
        this.timeout_frames = seconds*fps;
    }
}
//------------------------------------------------------------
//------------------------------------------------------------
class ServidorTCP extends sprite {
    // id del padre que es el que esta escuchando conexiones y
    // guarda la lista de sockets abiertos como este..
    // este socket al desconectarse se auto elimina de la lista del padre..
    // asi el padre tiene una lista de sockets activos abertos para hacer un posible broadcast..
    ServerTCP idServerListener;
    long counter = 0;
    sprite ID;                // puntero a un proceso, util para cualquier controlador de socket, player etc..
    Socket servicio = null;
    DataInputStream flujoDatosEntrada = null;
    DataOutputStream flujoDatosSalida = null;
    boolean connected = true;
    public ServidorTCP(ServerTCP idServ, Socket servicio, DataInputStream in, DataOutputStream out) {  //Constructor
        this.idServerListener = idServ;
        this.servicio = servicio;
        flujoDatosEntrada = in;
        flujoDatosSalida = out;
    }

    void initialize() {
        signal(this, s_protected);
        idServerListener.conections.add(this);
        onNetServerOpenTCP(this);
    }

    public void frame() {  //Esto es un metodo, que es lo que correra cada hilo de nustro servidor
        boolean av = available();
        while ( av ) {
            counter = 0;
            String data = read();                            // recibir del socket la info..
            StringList datum = new StringList();             // crear un stringlist de salida..
            String[] buffer = split(data, NET_TOK_DATA_TCP);     // trocear lo recibido del socket..
            for (int i=0; i<buffer.length; i++) {
                datum.append(buffer[i]);                     // inyectar los trozos al stringlist de salida..
            }
            onNetServerMessageTCP(this, datum);                               // enviar salida a la función que la va a interpretar..
            av = available();
        }

        if (true) {
            counter ++;
            if (counter>idServerListener.timeout_frames) {
                this.close();
                onNetServerCloseTCP(this);
            }
        }

        if (!connected) {
            signal(this, s_unprotected);
            signal(this, s_kill);
        }
    }
    //......................................

    //......................................
    boolean available() {
        try {
            if (flujoDatosEntrada.available()>0) {
                return true;
            }
        }
        catch(Exception e) {
        }
        return false;
    }
    //......................................
    String read() {
        try {
            String s = flujoDatosEntrada.readUTF();
            return s;
        }
        catch(Exception e) {
            return "ERROR recibiendo datagrama!";
        }
    }
    //......................................
    void write(String s) {
        try {
            flujoDatosSalida.writeUTF(s);
        }
        catch(Exception e) {
            println("ERROR enviando datagrama!");
        }
    }
    //......................................
    void write(netMessageTCP n) {
        write(n.buffer);
    }
    //......................................
    void write(StringList msg) {
        netMessageTCP n = new netMessageTCP(this);
        for (int i=0; i<msg.size(); i++) {
            n.add(msg.get(i));
        }
        write(n);
    }
    //......................................
    void close() {
        try {
            servicio.close();
            connected = false;
            idServerListener.conections.remove(this);
        }
        catch(Exception e) {
            println("ERROR al cerrar conexion!");
            connected = false;
        }
    }
    //......................................
}
//------------------------------------------------------------

//------------------------------------------------------------
class Client extends sprite {
    String ip = "";
    Socket conexion = null;
    int PUERTO = 5555;
    DataInputStream flujoDatosEntrada = null;
    DataOutputStream flujoDatosSalida = null;
    boolean connected = false;
    long counter = 0;
    long timeout_frames = fps*10;
    Client(String ip, int port) {
        this.ip = ip;
        this.PUERTO = port;
        conecta();
        //this.start();
    }
    void conecta() {
        try {
            conexion = new Socket(ip, PUERTO);
            flujoDatosEntrada = new DataInputStream(conexion.getInputStream());  //Crea un objeto para recibir mensajes del servidor
            flujoDatosSalida = new DataOutputStream(conexion.getOutputStream());//Creamos objeto para enviar
            //envia("Gracias por aceptarme");  //Mandamos el mensaje al servidor
            connected = true;
        }
        catch(Exception e) {
            println("ERROR No se pudo crear la conexion!");
            //e.printStackTrace();
        }
    }
    //......................................
    void close() {
        try {
            conexion.close();
        }
        catch(Exception e) {
            //e.printStackTrace();
        }
    }
    //......................................
    void initialize() {
        signal(this, s_protected);
    }
    //......................................
    void frame() {
        boolean av = available();
        while ( av ) {
            this.counter = 0;
            String data = read();                            // recibir del socket la info..
            StringList datum = new StringList();             // crear un stringlist de salida..
            String[] buffer = split(data, NET_TOK_DATA_TCP);     // trocear lo recibido del socket..
            for (int i=0; i<buffer.length; i++) {
                datum.append(buffer[i]);                     // inyectar los trozos al stringlist de salida..
            }
            onNetClientMessageTCP(this, datum);                 // enviar salida a la función que la va a interpretar..
            av = available();
        }

        if (true) {
            if (this.connected) {
                this.counter ++;
                if (this.counter>this.timeout_frames) {
                    this.close();
                    this.connected = false;
                    println("[CLIENT] Conection closed by timeout..");
                }
            }
        }
    }
    //......................................
    void write(String s) {
        if (!connected) {
            println("ERROR enviando, socket no conectado!");
        }
        try {
            flujoDatosSalida.writeUTF(s);
        }
        catch(Exception e) {
        }
    }
    //......................................
    void write(netMessageTCP n) {
        write(n.buffer);
    }
    //......................................
    String read() {
        try {
            String s = flujoDatosEntrada.readUTF();
            return s;
        }
        catch(Exception e) {
            return "ERROR recibiendo datagrama!";
        }
    }
    //......................................
    boolean available() {
        try {
            if (flujoDatosEntrada.available()>0) {
                return true;
            }
        }
        catch(Exception e) {
        }
        return false;
    }
    //......................................
    boolean isConnected() {
        return this.connected;
    }
    //......................................
    void setTimeout(int seconds) {
        this.timeout_frames = seconds*fps;
        this.counter = 0;
    }
    //......................................
    //......................................
    //......................................
}
//------------------------------------------------------------
//------------------------------------------------------------
/* CLASE MENSAJE DE RED.. */
class netMessageTCP {
    ServidorTCP socket_server;
    Client  socket_client;
    char delimitier = NET_TOK_DATA_TCP;
    String buffer = "";
    //-------------CONSTRUCTOR MSG----------------------------
    //--------------------------------------------------------
    public netMessageTCP(ServidorTCP s) {
        socket_server = s;
    }
    public netMessageTCP(Client c) {
        socket_client = c;
    }
    //-------------SIMPLE ADD DATA TO MSG---------------------
    //--------------------------------------------------------
    void add(String token) {
        if (buffer.length()==0) {
            buffer += token;
        } else {
            buffer += delimitier + token;
        }
    }
    //--------------------------------------------------------
    void add(int token) {
        this.add(str(token));
    }
    //--------------------------------------------------------
    void add(float token) {
        this.add(str(token));
    }
    //--------------------------------------------------------
    void add(boolean token) {
        this.add(str(token));
    }
    //--------------------------------------------------------
    void add(char token) {
        this.add(str(token));
    }
    //--------------------------------------------------------
    void add(long token) {
        this.add(str(token));
    }
    //--------------------------------------------------------
    //-------------COMPLEX ADD DATA TO MSG--------------------
    void add(StringList msg) {
        for (int i=0; i<msg.size(); i++) {
            this.add(msg.get(i));
        }
    }
    //-------------SIMPLE SEND MSG TO NETWORK-----------------
    //--------------------------------------------------------
    void send() {
        if (socket_server!=null) {
            socket_server.write(this.buffer);
        } else if (socket_client!=null) {
            socket_client.write(this.buffer);
        } else {
            println("Error sending buffer to NULL socket!");
        }
    }
    //--------------------------------------------------------
    //--------------------------------------------------------
    void broadcast() {
        if (socket_server!=null) {


            for (ServidorTCP s : this.socket_server.idServerListener.conections) {
                s.write(this.buffer);
            }
        } else if (socket_client!=null) {

            println("Error, only servers can broadcast msg");
        } else {
            println("Error sending buffer to NULL socket!");
        }
    }
    //--------------------------------------------------------
    void broadcast(boolean echo_to_me) {
        if (socket_server!=null) {


            for (ServidorTCP s : this.socket_server.idServerListener.conections) {
                if (echo_to_me) {
                    s.write(this.buffer);
                } else {
                    if (this.socket_server != s) {
                        s.write(this.buffer);
                    }
                }
            }
        } else if (socket_client!=null) {

            println("Error, only servers can broadcast msg");
        } else {
            println("Error sending buffer to NULL socket!");
        }
    }
    //--------------------------------------------------------
}
//------------------------------------------------------------
//------------------------------------------------------------
//import java.net.InetAddress;
//import java.net.NetworkInterface;
//import java.net.SocketException;
//import java.net.UnknownHostException;

public class getMac_ {

    public getMac_() {

        InetAddress ip;
        try {

            ip = InetAddress.getLocalHost();
            System.out.println("Current IP address : " + ip.getHostAddress());

            NetworkInterface network = NetworkInterface.getByInetAddress(ip);

            byte[] mac = network.getHardwareAddress();

            System.out.print("Current MAC address : ");

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < mac.length; i++) {
                sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
            }
            System.out.println(sb.toString());
        }
        catch (UnknownHostException e) {

            e.printStackTrace();
        }
        catch (SocketException e) {

            e.printStackTrace();
        }
    }
}



String getIp() {
    InetAddress ip;
    try {
        ip = InetAddress.getLocalHost();
        return ip.getHostAddress();
    }
    catch (Exception e) {
        e.printStackTrace();
        return "error";
    }
}

String getMac() {
    InetAddress ip;
    try {
        ip = InetAddress.getLocalHost();
        NetworkInterface network = NetworkInterface.getByInetAddress(ip);
        byte[] mac = network.getHardwareAddress();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < mac.length; i++) {
            sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
        }
        return sb.toString();
    }
    catch (Exception e) {
        e.printStackTrace();
        return "error";
    }
}
