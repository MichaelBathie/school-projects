// CLASS: Node
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of Node
// Defines the objects that are held in a list
// and how you can operate on them.
//
//-----------------------------------------

public class Node {
    private ListItem data;
    private Node next;

    //constructor.
    public Node(ListItem data, Node next) {
        this.data = data;
        this.next = next;
    }

    //return the string representation of the data in the node.
    public String toString() {
        return data.toString();
    }

    //check if there is another node in the list.
    public boolean nextCheck() {
        boolean hasNext = true;

        if(next == null) {
            hasNext = false;
        }
        return hasNext;
    }

    public void setNext(Node n){next = n;}
    public Node getNext(){return next;}
    public ListItem data(){return data;}
}
