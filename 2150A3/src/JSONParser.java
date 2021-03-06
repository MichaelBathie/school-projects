import java.util.*;

public class JSONParser {

    public JSONParser() {
        super();
    }

    public JSONObject read (String x) {
        Scanner s = new Scanner (x);
        return readObject(s);
    }

    private Value readValue (Scanner in) {

        Value li = null;
        if ( in.hasNext("\\{")) {
            li = readObject(in);
        } else if ( in.hasNext("\\[")) {
            li = readArray(in);
        } else {
            li = createValue(in);
        }

        return li;

    }

    private Value readArray (Scanner in) {

        String token = in.next().trim();
        JSONArray retVal = JSONFactory.getJSONArray();
        if ( token.equals("[")) {

            while (! in.hasNext("]")) {

                Value li = readValue(in);
                retVal.addValue(li);
                if (in.hasNext(",")) {
                    in.next(",");
                    // discard comma
                }
            }
            in.next ("]"); // discard }
        }
        return retVal;
    }

    private JSONObject readObject (Scanner in) {

        JSONObject retVal = JSONFactory.getJSONObject();
        String token = in.next().trim();

        if ( token.equals("{")) {

            while (! in.hasNext("}")) {
                Value key = createValue(in);

                if (! in.hasNext(":")) {
                    System.out.println("error! expected colon, found: " + token);
                } else {
                    in.next(":");
                    // discard :
                }


                Value li = readValue(in);
                retVal.addKeyValue(key,li);
                if (in.hasNext(",")) {
                    in.next(",");
                    // discard comma
                }
            }

            in.next ("}"); // discard }
        } else {
            System.out.println("error: expected {, found: " + token);
        }
        return retVal;
    }

    private String readString(Scanner in) {
        String token, out = "";
        token = in.next();
        out = token;
        while (!token.endsWith("\"")) {
            token = in.next();
            out+= " " + token;
        }
        return out;
    }

    public Value createValue(Scanner in) {

        Value li = null;
        String token;
        if (in.hasNext("\\d*(\\.\\d*)?")) {
            // integer
            token = in.next("\\d*(\\.\\d*)?");
            if ( token.contains(".")) {
                li = JSONFactory.getJSONValue(ValueEnum.DOUBLE,  Double.parseDouble(token));
            } else {
                li = JSONFactory.getJSONValue(ValueEnum.INT, Integer.parseInt(token));

            }
        } else if (in.hasNext("\\\"[^\\\"]*\\\"")) {
            // value
            token = in.next("\\\"[^\\\"]*\\\"");
            li = JSONFactory.getJSONValue(ValueEnum.STRING, token);

        } else if (in.hasNext("\\\".*")) {
            String out = readString(in);
            li = JSONFactory.getJSONValue(ValueEnum.STRING, out);

        } else if (in.hasNext("true|false")) {
            token = in.next("true|false");
            li = JSONFactory.getJSONValue(ValueEnum.BOOL, Boolean.parseBoolean(token));

        } else {
            System.out.println("error: expected value, found: " + in.next());
        }

        return li;
    }

}
