public interface JSONQueryManager{
    public void loadJSON (String JSON) ;
    public Value getJSONValue (String query) throws IllegalStateException;
}