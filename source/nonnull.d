module nonnull;

import core.exception: AssertError;

import std.exception: assertThrown, enforce;
import std.traits: isMutable, isPointer;



/** 
 * A pointer wrapper that ensures it doesn't point to null.
 */
struct NonNull(T) if (isPointer!T)
{
    alias PointeeType = typeof(*m_p);

    /** 
     * Disable default initialization
     */
    this() @disable;

    /** 
     * Disable initialization with null
     */
    this(typeof(null)) @disable;

    /** 
     * Initialize with a raw pointer.
     */
    this(T rhs)
    {
        enforce!AssertError(rhs != null);
        m_p = rhs;
    }

    /** 
     * Copy constructor
     */
    this(U)(NonNull!U rhs) if (is(U : T))
    {
        m_p = rhs.m_p;
    }

    /** 
     * Disable assigning with null 
     */
    void opAssign(typeof(null)) @disable;

    // if T is not const nor immutable, we can provide assignment operators
    static if (isMutable!T)
    {

        /** 
         * Assignment operator with a raw pointer
         */
        auto opAssign(T rhs)
        {
            enforce!AssertError(rhs != null);
            m_p = rhs;
            return this;
        }

        /** 
         * Assignment operator with a non-null pointer.
         */
        auto opAssign(U)(NonNull!U rhs) if (is(U : T))
        {
            m_p = rhs.m_p;
            return this;
        }
    }

    /** 
     * Dererefencing operator 
     */
    ref PointeeType opUnary(string op: "*")()
    {
        return *m_p;
    }

    T get() 
    {
        return m_p;
    }

private:
    T m_p;
}

unittest 
{
    // Check initialize with raw pointer
    {
        int i;
        NonNull!(int*) pi = &i;

        void func()
        {
            int* p = null;
            NonNull!(int*) pi = p;
        }

        assertThrown!AssertError(func());
    }

    // Check copy constructor
    {
        int i;
        NonNull!(int*) pi = &i;
        NonNull!(const int*) pi2 = pi;
    }

    // Check assignment operator 
    {
        int i, j;
        NonNull!(int*) p = &i;
        p = &j;

        void func()
        {
            int* pn = null;
            p = pn;
        }

        assertThrown!AssertError(func());
    }

    // Check assignment operator 
    {
        int i, j;
        NonNull!(int*) pi = &i;
        NonNull!(const(int)*) pi2 = pi;
        NonNull!(const(int)*) pi3 = &j;
        pi2 = pi3;
    }

    // Check dereferencing operator 
    {
        int i;
        NonNull!(int*) pi = &i;
        *pi = 42;

        assert (i == 42);
    }
}