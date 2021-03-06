// CLASS: ObjectValue
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of ObjectValue.
// Defines an ObjectValue and how you can operate on it.
//
//-----------------------------------------

public class ObjectValue implements JSONObject, Value {
    private List object;

    //constructor.
    public ObjectValue() {
        object = new List();
    }

    //------------------------------------------------------
    // addKeyValue
    //
    // PURPOSE:    add a KeyValuePair to this ObjectValue.
    // PARAMETERS:
    //     Value key: the key that we want to add.
    //     Value v: the value that we want to add.
    //------------------------------------------------------
    public void addKeyValue(Value key, Value v) {
        //if the key is a StringValue
        if(key instanceof StringValue) {
            //check if there is a duplicate.
            KeyValuePair dup = object.dupCheck(key);
            //if there is
            if(dup != null) {
                //just replace the value.
                dup.valueReplace(v);
            }
            //otherwise.
            else {
                //add the new KeyValuePair to the list.
                KeyValuePair kvp = new KeyValuePair(key, v);
                object.add(kvp);
            }
        }
    }

    public Value getValue (Value key) {
        return object.keySearch(key);
    }

    //make a new iterator on the current instance.
    public JSONIter iterator () {
        return new Iter(object);
    }

    //------------------------------------------------------
    // toString
    //
    // PURPOSE:    Defines a String representation of the object.
    //
    // Returns: The String representation of the this instance.
    //------------------------------------------------------
    public String toString() {
        String message = "{ ";

        message += object.listString() + "}";

        return message;
    }

    //private helper method for equals.
    private boolean equalsHelper(Value v1, Value v2) {
        Value v = object.keySearch(v1);
        return v.equals(v2);
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
        ObjectValue ov;
        JSONIter iterator = null;
        JSONIter iterator1 = iterator();

        //if v is an ObjectValue
        if(v instanceof ObjectValue) {
            //cast it to that.
            ov = (ObjectValue)v;
            //make an iterator on it.
            iterator = ov.iterator();

            //while our new iterator and the iterator of the current instance
            //still have more items.
            while(iterator.hasNext() && iterator1.hasNext()) {
                //grab the next key.
                Value key = iterator.getNext();
                //just iterate, don't need the item.
                iterator1.getNext();
                //check the current instance for the key.
                Value val2 = object.keySearch(key);

                //if we didn't find the key or if the values aren't equal.
                if(val2.toString().equals("\"\"") || !ov.equalsHelper(key,val2)) {
                    equal = false;
                    break;
                }
            }
            //if one iterator ends before the other.
            if(iterator.hasNext() || iterator1.hasNext())
                equal = false;
        }
        //if it's not an instance of ObjectValue
        else {
            equal = false;
        }
        return equal;
    }
}
