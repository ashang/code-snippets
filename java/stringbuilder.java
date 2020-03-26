// deb/apt
//     sudo apt install default-jdk-headless
// rpm/dnf
//     java:  sudo dnf -v install java-latest-openjdk
//     javac: sudo dnf -v install java-latest-openjdk-devel

public class stringbuilder {
    //public static void main(String []args) {
    public static void main(String... args) {
        final StringBuilder sb = new StringBuilder();
        sb.append("Hello");
        sb.append(' ');
        sb.append("StringBuilder");
        sb.append('!');
        System.out.println(sb.toString());
    }
}
