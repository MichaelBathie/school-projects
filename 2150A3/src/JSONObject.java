public interface JSONObject extends Value {
    public void addKeyValue( Value key, Value v);
    public Value getValue (Value key);
    public JSONIter iterator ();
}
