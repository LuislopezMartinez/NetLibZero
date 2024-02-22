/*

 http://tutorials.jenkov.com/java-nio/files.html#overwriting-existing-files
 
 */



import java.nio.file.*;
/*
void fileCopy( String source, String destination, boolean overwrite ){
 Path sourcePath      = Paths.get( source );
 Path destinationPath = Paths.get( destination );
 
 try {
 if(overwrite){
 Files.copy(sourcePath, destinationPath, StandardCopyOption.REPLACE_EXISTING);
 } else{
 Files.copy(sourcePath, destinationPath);
 }
 } catch(FileAlreadyExistsException e) {
 //destination file already exists
 } catch (IOException e) {
 //something else went wrong
 e.printStackTrace();
 }
 }
 */
//------------------------------------------------------------
boolean fileExists(String filename) {
    File file=new File( filename );
    //println(file.getName());
    boolean exists = file.exists();
    if (exists) {
        //println("true");
        return true;
    } else {
        //println("false");
        return false;
    }
}
//------------------------------------------------------------
void mkDir( String folderName ) {
    File dir = new File( folderName );
    dir.mkdir();
}
//------------------------------------------------------------
//------------------------------------------------------------
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.Writer;
//------------------------------------------------------------
void writeLine( String filename, String newLine ) {
    // append = true
    try {
        PrintWriter output = new PrintWriter(new FileWriter( filename, true ));
        output.printf("%s\r\n", newLine);
        output.flush();
        output.close();
    }
    catch (Exception e) {
        e.printStackTrace();
    }
}
void writeLine( String filename, String newLine, Boolean append ) {
    // append = true
    try {
        PrintWriter output = new PrintWriter(new FileWriter( filename, append ));
        output.printf("%s\r\n", newLine);
        output.flush();
        output.close();
    }
    catch (Exception e) {
        e.printStackTrace();
    }
}
//------------------------------------------------------------
void writeLines( String filename, StringList lines ) {
    // append = true
    try {
        PrintWriter output = new PrintWriter(new FileWriter( filename, true ));
        for (int i=0; i<lines.size(); i++) {
            output.printf("%s\r\n", lines.get(i));
        }
        output.flush();
        output.close();
    } 
    catch (Exception e) {
    }
}
void writeLines( String filename, StringList lines, Boolean append ) {
    // append = true
    try {
        PrintWriter output = new PrintWriter(new FileWriter( filename, append ));
        for (int i=0; i<lines.size(); i++) {
            output.printf("%s\r\n", lines.get(i));
        }
        output.flush();
        output.close();
    } 
    catch (Exception e) {
    }
}
//------------------------------------------------------------
void deleteFile( String filename ) {
    File fichero = new File( filename );
    if (fichero.delete()) {
        println(filename + " eliminado con exito.");
    } else {
        println(filename + " no se pudo eliminar.");
    }
}
//------------------------------------------------------------
void deleteFile( String filename, boolean dataPathMode ) {
    File fichero;
    if (dataPathMode) {
        fichero = new File(dataPath(filename));
    } else {
        fichero = new File(filename);
    }
    if (fichero.delete()) {
        println(filename + " eliminado con exito.");
    } else {
        println(filename + " no se pudo eliminar.");
    }
}
//------------------------------------------------------------
