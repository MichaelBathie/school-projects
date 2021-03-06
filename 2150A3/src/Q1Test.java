//-----------------------------------------
// NAME		: Michael Bathie
// STUDENT NUMBER	: 7835010
// COURSE		: COMP 2150
// INSTRUCTOR	: Mike Domaratzki
// ASSIGNMENT	: assignment 3
// QUESTION	: question 1
//
// REMARKS: This purpose of this program is to
// test the implementations of the Value interface.
//
//
//-----------------------------------------

import static org.junit.Assert.*;
import org.junit.Test;

public class Q1Test {

    /*
    INT VALUE TESTS
     */

    @Test
    public void testIntValue() {
        //test create
        IntValue i = new IntValue(8);
        assertEquals("should be 8", "8", i.toString());
    }

    @Test
    public void testIntValueEqualsTrue() {
        //test equals
        IntValue i = new IntValue(10);
        IntValue i2 = new IntValue(10);

        assertTrue("should be true", i.equals(i2));
    }

    @Test
    public void testIntValueEqualsFalse() {
        //test equals
        IntValue i = new IntValue(10);
        IntValue i2 = new IntValue(9);

        assertFalse("should be false", i.equals(i2));
    }

    /*
    DOUBLE VALUE TESTS
     */

    @Test
    public void testDoubleValue() {
        //test create
        DoubleValue d = new DoubleValue(8);
        assertEquals("should be 8.0", "8.0", d.toString());
    }

    @Test
    public void testDoubleValueEqualsTrue() {
        //test equals
        DoubleValue i = new DoubleValue(10);
        DoubleValue i2 = new DoubleValue(10);

        assertTrue("should be true", i.equals(i2));
    }

    @Test
    public void testDoubleValueEqualsFalse() {
        //test equals
        DoubleValue i = new DoubleValue(10);
        DoubleValue i2 = new DoubleValue(9);

        assertFalse("should be false", i.equals(i2));
    }

    /*
    BOOL VALUE TESTS
     */

    @Test
    public void testBoolValue() {
        //test create
        BoolValue b = new BoolValue(true);
        assertEquals("should be true", "true", b.toString());
    }

    @Test
    public void testBoolValueEqualsTrue() {
        //test equals
        BoolValue i = new BoolValue(true);
        BoolValue i2 = new BoolValue(true);

        assertTrue("should be true", i.equals(i2));
    }

    @Test
    public void testBoolValueEqualsFalse() {
        //test equals
        BoolValue i = new BoolValue(true);
        BoolValue i2 = new BoolValue(false);

        assertFalse("should be false", i.equals(i2));
    }

    /*
    STRING VALUE TESTS
     */

    @Test
    public void testStringValue() {
        //test create
        StringValue s = new StringValue("test");
        assertEquals("should be test", "\"test\"", s.toString());
    }

    @Test
    public void testStringValueEqualsTrue() {
        //test equals
        StringValue i = new StringValue("equal");
        StringValue i2 = new StringValue("equal");

        assertTrue("should be true", i.equals(i2));
    }

    @Test
    public void testStringValueEqualsFalse() {
        //test equals
        StringValue i = new StringValue("name");
        StringValue i2 = new StringValue("number");

        assertFalse("should be false", i.equals(i2));
    }

    /*
    ARRAY VALUE TESTS
     */

    @Test
    public void testArrayValue() {
        //test create
        ArrayValue a = new ArrayValue();
        assertEquals("should be empty", "[ ]", a.toString());
    }

    @Test
    public void testArrayAdd() {
        //test add
        ArrayValue a = new ArrayValue();
        a.addValue(new IntValue(5));

        assertEquals("should contain 5", "[ 5 ]", a.toString());
    }

    @Test
    public void testArrayEqualsTrue() {
        //test equals
        ArrayValue a = new ArrayValue();
        ArrayValue b = new ArrayValue();
        Value v = new IntValue(1);
        Value v1 = new DoubleValue(5);
        Value v2 = new StringValue("testing");
        Value v3 = new BoolValue(true);

        a.addValue(v); a.addValue(v1); a.addValue(v2); a.addValue(v3);
        b.addValue(v); b.addValue(v1); b.addValue(v2); b.addValue(v3);

        assertTrue("should be equal", a.equals(b));
    }

    @Test
    public void testArrayEqualsFalse() {
        //test equals
        ArrayValue a = new ArrayValue();
        ArrayValue b = new ArrayValue();
        Value v = new IntValue(1);
        Value v1 = new DoubleValue(5);
        Value v2 = new StringValue("testing");
        Value v3 = new BoolValue(true);
        Value v4 = new DoubleValue(6);

        a.addValue(v); a.addValue(v1); a.addValue(v2); a.addValue(v3);
        b.addValue(v); b.addValue(v1); b.addValue(v2); b.addValue(v3); a.addValue(v4);

        assertFalse("should not be equal", a.equals(b));
    }

    /*
    OBJECT VALUE TESTS
     */

    @Test
    public void testObjectValue() {
        //test create
        ObjectValue o = new ObjectValue();
        assertEquals("should be empty", "{ }", o.toString());
    }

    @Test
    public void testObjectAdd() {
        //test add
        ObjectValue o = new ObjectValue();
        o.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        o.addKeyValue(new StringValue("number"), new IntValue(6));

        assertEquals("should contain a name and a number", "{ \"name\" : \"Michael\" , \"number\" : 6 }", o.toString());
    }

    @Test
    public void testObjectGetValueEmpty() {
        ObjectValue o = new ObjectValue();
        assertEquals("should be empty", "\"\"", o.getValue(new StringValue("number")).toString());
    }

    @Test
    public void testObjectGetValue() {
        ObjectValue o = new ObjectValue();
        o.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        o.addKeyValue(new StringValue("number"), new IntValue(6));

        assertEquals("should give 6", "6", o.getValue(new StringValue("number")).toString());
    }

    @Test
    public void testObjectKeyNotEqual() {
        ObjectValue o = new ObjectValue();
        ObjectValue q = new ObjectValue();
        o.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        q.addKeyValue(new StringValue("number"), new StringValue("Michael"));

        assertFalse("should not be equal", o.equals(q));
    }

    @Test
    public void testObjectValNotEqual() {
        ObjectValue o = new ObjectValue();
        ObjectValue q = new ObjectValue();
        o.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        q.addKeyValue(new StringValue("name"), new StringValue("Bathie"));

        assertFalse("should not be equal", o.equals(q));
    }

    @Test
    public void testObjectEquals() {
        ObjectValue o = new ObjectValue();
        ObjectValue q = new ObjectValue();

        ArrayValue b = new ArrayValue();
        b.addValue(new StringValue("fdf"));
        b.addValue(new IntValue(8));

        ArrayValue a = new ArrayValue();
        a.addValue(new StringValue("fdf"));
        a.addValue(new IntValue(7));
        a.addValue(b);

        ObjectValue o1 = new ObjectValue();
        ObjectValue q1 = new ObjectValue();

        o1.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        o1.addKeyValue(new StringValue("number"), new IntValue(6));
        q1.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        q1.addKeyValue(new StringValue("number"), new IntValue(6));
        o1.addKeyValue(new StringValue("list"), a);
        q1.addKeyValue(new StringValue("list"), b);

        o.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        o.addKeyValue(new StringValue("number"), new IntValue(6));
        q.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        q.addKeyValue(new StringValue("number"), new IntValue(6));
        o.addKeyValue(new StringValue("list"), a);
        q.addKeyValue(new StringValue("list"), a);


        assertTrue("should be equal", o.equals(q));
    }

    @Test
    public void testObjectNotEquals() {
        ObjectValue o = new ObjectValue();
        ObjectValue q = new ObjectValue();

        ArrayValue a = new ArrayValue();
        a.addValue(new StringValue("fdf"));
        a.addValue(new IntValue(7));

        ArrayValue b = new ArrayValue();
        b.addValue(new StringValue("THIS IS THE ONLY THING THAT'S DIFFERENT"));
        b.addValue(new IntValue(7));
        b.addValue(a);

        ObjectValue o1 = new ObjectValue();
        ObjectValue q1 = new ObjectValue();

        o1.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        o1.addKeyValue(new StringValue("number"), new IntValue(6));
        q1.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        q1.addKeyValue(new StringValue("number"), new IntValue(6));
        o1.addKeyValue(new StringValue("list"), a);
        q1.addKeyValue(new StringValue("list"), b);

        o.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        o.addKeyValue(new StringValue("number"), new IntValue(6));
        q.addKeyValue(new StringValue("name"), new StringValue("Michael"));
        q.addKeyValue(new StringValue("number"), new IntValue(6));
        o.addKeyValue(new StringValue("list"), a);
        q.addKeyValue(new StringValue("list"), b);
        o.addKeyValue(new StringValue("itself"), o1);
        q.addKeyValue(new StringValue("itself"), q1);


        assertFalse("should not be equal", o.equals(q));
    }

}
