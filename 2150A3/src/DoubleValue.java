// CLASS: DoubleValue
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of DoubleValue
//
//-----------------------------------------

public class DoubleValue implements Value {

    private double val;

    //constructor
    public DoubleValue(double val) {
        this.val = val;
    }

    //------------------------------------------------------
    // toString
    //
    // PURPOSE:    Defines a String representation of the object.
    //
    // Returns: The String representation of the this instance.
    //------------------------------------------------------
    public String toString() {
        return val+"";
    }

    //private helper for the equals method.
    private boolean numEqual(double num) {
        return num == val;
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

        //make sure v is a DoubleValue.
        if(v instanceof DoubleValue) {
            //cast v to a DoubleValue.
            DoubleValue d = (DoubleValue) v;
            //call the private helper
            if(d.numEqual(val))
                equal = true;
        }
        return equal;
    }
}
