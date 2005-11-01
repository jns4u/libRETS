namespace std {
  template<class T> class auto_ptr
  {
    public:
      auto_ptr();
      auto_ptr(T * t);
      T * operator-> () const;
      void reset(T * t);
  };
}


%define SWIG_AUTO_PTR_RELEASE_PROXY(TYPE, PROXYCLASS)
    
#if defined(SWIGCSHARP)

%typemap (ctype) std::auto_ptr<TYPE> "void *"
%typemap (imtype, out="IntPtr") std::auto_ptr<TYPE> "HandleRef"
%typemap (cstype) std::auto_ptr<TYPE> "PROXYCLASS"
%typemap (out) std::auto_ptr<TYPE> %{
  $result = (void *)$1.release();
%}
%typemap(csout, excode=SWIGEXCODE) std::auto_ptr<TYPE> {
    IntPtr cPtr = $imcall;
    PROXYCLASS ret = (cPtr == IntPtr.Zero) ? null : new PROXYCLASS(cPtr, true);$excode
    return ret;
  }

#elif defined(SWIGPERL)

%typemap(out) std::auto_ptr<TYPE>
    "ST(argvi) = sv_newmortal();
     SWIG_MakePtr(ST(argvi++), (void *) $1.release(), $descriptor(TYPE *), $shadow|$owner);";

#else

%typemap(out) std::auto_ptr<TYPE>
    "$result = SWIG_NewPointerObj((void *) $1.release(), $descriptor(TYPE *), $owner);"

#endif

%template() std::auto_ptr<TYPE>;
%enddef
;

%define SWIG_AUTO_PTR_RELEASE(TYPE)
    SWIG_AUTO_PTR_RELEASE_PROXY(TYPE, TYPE)
%enddef

SWIG_AUTO_PTR_RELEASE(Foo)
    ;
%define SWIG_RELEASE_AUTO_PTR(RETURN_TYPE, METHOD_NAME, PROTO, ARGS)
    %extend {
    RETURN_TYPE * METHOD_NAME PROTO {
        std::auto_ptr<RETURN_TYPE> auto_result = self->METHOD_NAME ARGS;
        return auto_result.release();
    }
}
%enddef