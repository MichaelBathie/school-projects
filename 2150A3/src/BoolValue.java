// CLASS: BoolValue
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of BoolValue
//
//-----------------------------------------

public class BoolValue implements Value {

    private boolean bool;

    //constructor.
    public BoolValue(boolean bool) {
        this.bool = bool;
    }

    //------------------------------------------------------
    // toString
    //
    // PURPOSE:    Defines a String representation of the object.
    //
    // Returns: The String representation of the this instance.
    //------------------------------------------------------
    public String toString() {
        String message;
        if(bool)
            message = "true";
        else
            message = "false";
        return message;
    }

    //private helper for the equals method.
    private boolean BoolEqual(boolean b) {
        return b == bool;
    }

    //------------------------------------------------------
    // equals
    //
    // PURPOSE:    Checks if two objects of this class are
    // equal to each other.
    // PARAMETERS:
    //     Value v: check if the current instance is equal to this.
    //
    // Returns: boolean of if they're equal or not.
    //------------------------------------------------------
    public boolean equals(Value v) {
        boolean equal = false;

        //make sure v is a BoolValue
        if(v instanceof BoolValue) {
            //cast v to a BoolValue
            BoolValue b = (BoolValue)v;
            //use the private helper method.
            if(b.BoolEqual(bool))
                equal = true;
        }
        return equal;
    }
}
