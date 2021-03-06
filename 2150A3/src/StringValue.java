// CLASS: StringValue
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of StringValue.
// Defines a StringValue and how you can operate on it.
//
//-----------------------------------------

public class StringValue implements Value {

    private String identifier;

    public StringValue(String identifier) {
        this.identifier = identifier;
    }

    //------------------------------------------------------
    // toString
    //
    // PURPOSE:    Defines a String representation of the object.
    //
    // Returns: The String representation of the this instance.
    //------------------------------------------------------
    public String toString() {
        return "\""+identifier+"\"";
    }

    //private helper for equals.
    private boolean StringEqual(String s) {return identifier.equals(s);}

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

        //if v is a StringValue
        if(v instanceof StringValue) {
            //cast it to that.
            StringValue s = (StringValue)v;
            //call the private helper.
            if(s.StringEqual(identifier)) {
                equal = true;
            }
        }
        return equal;
    }
}
