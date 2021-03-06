// CLASS: ArrayValue
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of ArrayValue
//
//-----------------------------------------

public class ArrayValue implements JSONArray, Value {
    private List array;

    //constructor
    public ArrayValue() {
        array = new List();
    }

    //------------------------------------------------------
    // toString
    //
    // PURPOSE:    Defines a String representation of the object.
    //
    // Returns: The String representation of the this instance.
    //------------------------------------------------------
    public String toString() {
        String message = "[ ";

        message += array.listString() + "]";

        return message;
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
        boolean equal = true;
        JSONIter i1 = this.iterator();
        JSONIter i2;

        //make sure v is an ArrayValue
        if(v instanceof ArrayValue) {
            ArrayValue a = (ArrayValue)v;
            i2 = a.iterator();

            //if the iterators aren't at the end.
            while(i1.hasNext() && i2.hasNext()) {
                //if the values aren't equal.
                if(!(i1.getNext().equals(i2.getNext()))){
                    equal = false;
                }
            }
            //if one iterator is done but the other isn't
            if(i1.hasNext() || i2.hasNext())
                equal = false;
        }
        //if it's not an instance of ArrayValue.
        else
            equal = false;

        return equal;
    }

    //------------------------------------------------------
    // addValue
    //
    // PURPOSE:    Add a value to this array.
    // PARAMETERS:
    //     Value v: Value to be added to the array.
    // Returns: describe the return value
    //------------------------------------------------------
    public void addValue(Value v) {
        array.add(v);
    }

    //------------------------------------------------------
    // iterator
    //
    // PURPOSE:    create a new iterator over this object.
    // Returns: An iterator pointing to this array.
    //------------------------------------------------------
    public JSONIter iterator() {
        return new Iter(array);
    }
}
