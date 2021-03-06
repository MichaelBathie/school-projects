// CLASS: JSONFactory
//
// Author: Michael Bathie, 7835010
//
// REMARKS: The implementation of JSONFactory.
// Allows the creation of new Values
//
//-----------------------------------------

public class JSONFactory {

    //return a new ObjectValue
    public static JSONObject getJSONObject() {return new ObjectValue();}

    //return a new ArrayValue.
    public static JSONArray getJSONArray() {return new ArrayValue();}

    //return a Value of the specified type.
    public static Value getJSONValue(ValueEnum v, Object o) {
        Value newValue;

        if(v == ValueEnum.BOOL)
            newValue = (BoolValue)o;
        else if(v == ValueEnum.INT)
            newValue = (IntValue)o;
        else if(v == ValueEnum.DOUBLE)
            newValue = (DoubleValue)o;
        else
            newValue = (StringValue)o;

        return newValue;
    }
}
