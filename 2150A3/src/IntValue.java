// CLASS: IntValue
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of IntValue
//
//-----------------------------------------

public class IntValue implements Value {

    private int val;

    //constructor.
    public IntValue(int val) {
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

    //private helper method for equals.
    private boolean numEqual(int num) {
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

        //make sure v is an IntValue.
        if(v instanceof IntValue) {
            //cast v to IntValue.
            IntValue i = (IntValue)v;
            //call the private helper.
            if(i.numEqual(val))
                equal = true;
        }
        return equal;
    }
}
