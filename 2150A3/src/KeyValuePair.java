// CLASS: KeyValuePair
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of KeyValuePair.
// An object that can hold a key and a value.
//
//-----------------------------------------

public class KeyValuePair implements ListItem, Value {
    private Value key;
    private Value value;

    //constructor
    public KeyValuePair(Value key, Value value) {
        this.key = key;
        this.value = value;
    }

    //------------------------------------------------------
    // toString
    //
    // PURPOSE:    Defines a String representation of the object.
    //
    // Returns: The String representation of the this instance.
    //------------------------------------------------------
    public String toString() {
        return key.toString()+" : "+value.toString();
    }

    //private helper method for equals
    private boolean KVPEqual(Value key, Value value) {
        boolean equal = false;

        //if the key is a StringValue
        if(key instanceof StringValue) {

            //if the keys are equal
            if(key.equals(key)) {
                //if the values are equal
                if(value.equals(value)) {
                    equal = true;
                }
            }
        }
        return equal;
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

        //if v is a KeyValuePair
        if(v instanceof KeyValuePair) {
            //cast it to that.
            KeyValuePair k = (KeyValuePair)v;
            //call the private helper.
            if(k.KVPEqual(key,value))
                equal = true;
        }
        return equal;
    }

    public Value key() {return key;}
    public Value getVal() {return value;}
    //replace a key's associated value.
    public void valueReplace(Value v) {
        value = v;
    }
}
