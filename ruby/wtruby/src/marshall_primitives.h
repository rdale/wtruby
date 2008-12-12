/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#ifndef MARSHALL_PRIMITIVES_H
#define MARSHALL_PRIMITIVES_H

template <>
bool ruby_to_primitive<bool>(VALUE v)
{
    if (TYPE(v) == T_OBJECT) {
        // A Wt::Boolean has been passed as a value
        VALUE temp = rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("get_wboolean"), 1, v);
        return (temp == Qtrue ? true : false);
    } else {
        return (v == Qtrue ? true : false);
    }
}

template <>
VALUE primitive_to_ruby<bool>(bool sv)
{
    return sv ? Qtrue : Qfalse;
}

template <>
signed char ruby_to_primitive<signed char>(VALUE v)
{
    return NUM2CHR(v);
}

template <>
VALUE primitive_to_ruby<signed char>(signed char sv)
{
    return CHR2FIX(sv);
}

template <>
unsigned char ruby_to_primitive<unsigned char>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else {
        return NUM2CHR(v);
    }
}

template <>
VALUE primitive_to_ruby<unsigned char>(unsigned char sv)
{
    return CHR2FIX(sv);
}

template <>
short ruby_to_primitive<short>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else {
        return (short)NUM2INT(v);
    }
}

template <>
VALUE primitive_to_ruby<short>(short sv)
{
    return INT2NUM(sv);
}

template <>
unsigned short ruby_to_primitive<unsigned short>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else {
        return (unsigned short)NUM2UINT(v);
    }
}

template <>
VALUE primitive_to_ruby<unsigned short>(unsigned short sv)
{
    return UINT2NUM((unsigned int) sv);
}

template <>
int ruby_to_primitive<int>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else if (TYPE(v) == T_OBJECT) {
        return (int)NUM2INT(rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("get_winteger"), 1, v));
    } else {
        return (int)NUM2INT(v);
    }
}

template <>
VALUE primitive_to_ruby<int>(int sv)
{
    return INT2NUM(sv);
}

template <>
unsigned int ruby_to_primitive<unsigned int>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else if (TYPE(v) == T_OBJECT) {
        return (unsigned int) NUM2UINT(rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("get_winteger"), 1, v));
    } else {
        return (unsigned int) NUM2UINT(v);
    }
}

template <>
VALUE primitive_to_ruby<unsigned int>(unsigned int sv)
{
    return UINT2NUM(sv);
}

template <>
long ruby_to_primitive<long>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else if (TYPE(v) == T_OBJECT) {
        return (long) NUM2LONG(rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("get_winteger"), 1, v));
    } else {
        return (long) NUM2LONG(v);
    }
}

template <>
VALUE primitive_to_ruby<long>(long sv)
{
    return INT2NUM(sv);
}

template <>
unsigned long ruby_to_primitive<unsigned long>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else if (TYPE(v) == T_OBJECT) {
        return (unsigned long) NUM2ULONG(rb_funcall(Wt::Ruby::wt_internal_module, rb_intern("get_winteger"), 1, v));
    } else {
        return (unsigned long) NUM2ULONG(v);
    }
}

template <>
VALUE primitive_to_ruby<unsigned long>(unsigned long sv)
{
    return INT2NUM(sv);
}

template <>
long long ruby_to_primitive<long long>(VALUE v)
{
    if (v == Qnil) {
        return 0;
    } else {
        return NUM2LL(v);
    }
}

template <>
VALUE primitive_to_ruby<long long>(long long sv)
{
    return LL2NUM(sv);
}

template <>
unsigned long long ruby_to_primitive<unsigned long long>(VALUE v)
{
    return rb_num2ull(v);
}

template <>
VALUE primitive_to_ruby<unsigned long long>(unsigned long long sv)
{
    return rb_ull2inum(sv);
}

template <>
float ruby_to_primitive<float>(VALUE v)
{
    if (v == Qnil) {
        return 0.0;
    } else {
        return (float) NUM2DBL(v);
    }
}

template <>
VALUE primitive_to_ruby<float>(float sv)
{
    return rb_float_new((double) sv);
}

template <>
double ruby_to_primitive<double>(VALUE v)
{
    if (v == Qnil) {
        return 0.0;
    } else {
        return (double) NUM2DBL(v);
    }
}

template <>
VALUE primitive_to_ruby<double>(double sv)
{
    return rb_float_new((double) sv);
}

template <>
char* ruby_to_primitive<char *>(VALUE rv)
{
    if(rv == Qnil)
        return 0;

    return StringValuePtr(rv);
}

template <>
unsigned char* ruby_to_primitive<unsigned char *>(VALUE rv)
{
    if(rv == Qnil)
        return 0;
    
    int len = RSTRING(rv)->len;
    char* mem = (char*) malloc(len+1);
    memcpy(mem, StringValuePtr(rv), len);
    mem[len] ='\0';
    return (unsigned char*) mem;
}

template <>
VALUE primitive_to_ruby<int*>(int* sv)
{
    if(!sv) {
        return Qnil;
    }
    
    return primitive_to_ruby<int>(*sv);
}

#endif
