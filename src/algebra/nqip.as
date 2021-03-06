\documentclass{article}
\usepackage{axiom}
\begin{document}
\title{\$SPAD/src/algebra nqip.as}
\author{Michael Richardson}
\maketitle
\begin{abstract}
\end{abstract}
\eject
\tableofcontents
\eject
\section{NagQuadratureInterfacePackage}
<<NagQuadratureInterfacePackage>>=
+++ Author: M.G. Richardson
+++ Date Created: 1995 Dec. 07
+++ Date Last Updated:
+++ Basic Functions:
+++ Related Constructors:
+++ Also See:
+++ AMS Classifications:
+++ Keywords:
+++ References:
+++ Description:
+++ This package provides Axiom-like interfaces to some of the NAG
+++ quadrature (numerical integration) routines in the NAGlink.

NagQuadratureInterfacePackage: with {

  nagPolygonIntegrate : (LDF, LDF) ->
			        RCD(integral : DF, errorEstimate : DF) ;

  ++ nagPolygonIntegrate(xlist,ylist) evaluates the definite integral
#if saturn
  ++ $\int_{x_{1}}^{x_{n}}y(x) \, dx$
#else
  ++ integrate(y(x), x=x[1]..x[n])
#endif
  ++ where the numerical value of the function \spad{y} is specified at
  ++ the \spad{n} distinct points
#if saturn
  ++ $x_{1}, x_{2}, \ldots , x_{n}$.
#else
  ++ x[1], x[2] ... x[n].
#endif
  ++ The \spad{x} and \spad{y} values are specified in the lists
  ++ \spad{xlist} and \spad{ylist}, respectively; the \spad{xlist}
  ++ values must form a strictly monotonic sequence of four or more
  ++ points.
  ++ The calculation is performed by the NAG routine D01GAF.
  ++
  ++ An estimate of the numerical error in the calculation is also
  ++ returned; however, by choosing unrepresentative data points to
  ++ approximate the function it is possible to achieve an arbitrarily
  ++ large difference between the true integral and the value
  ++ calculated.
  ++ For more detailed information, please consult the NAG
  ++ manual via the Browser page for the operation d01gaf.

  nagPolygonIntegrate : MDF -> RCD(integral : DF, errorEstimate : DF) ;


} == add {

  import from NagIntegrationPackage ;
  import from NagResultChecks ;
  import from AnyFunctions1 DF ;
  import from STRG ;
  import from List STRG ;
  import from Symbol ;
  import from LLDF ;
  import from VDF ;
  import from MDF ;
  import from ErrorFunctions ;

  local ipIfail : INT := -1 ;
  local d01gafError : DF := 0 ;

  nagPolygonIntegrate(xlist : LDF, ylist : LDF)
		     : RCD(integral : DF, errorEstimate : DF) == {

    local lx, ly : INT ;
    local d01gafResult : RSLT ;

    lx := (# xlist) pretend INT ;
    ly := (# ylist) pretend INT ;
    if lx ~= ly
    then error ["The lists supplied to nagPolygonIntegrate are of ",
		"different lengths: ",
		string(lx),
		" and ",
		string(ly),
		"."]
    else {
      d01gafResult := d01gaf(matrix [xlist],matrix [ylist],lx,ipIfail) ;
      [checkResult(d01gafResult,"ans","D01GAF"),
       retract(d01gafResult."er") @ DF]
    }
  }

  nagPolygonIntegrate(coords : MDF)
		     : RCD(integral : DF, errorEstimate : DF) ==
    if (ncols(coords) pretend INT) ~= 2
    then error ["Please supply the coordinate matrix in ",
		"nagPolygonIntegrate with each row consisting of ",
		"a single x-y pair."]
    else nagPolygonIntegrate(members column(coords,1),
		             members column(coords,2)) ;

}

#if NeverAssertThis

-- Note that the conversions of results from DoubleFloat to Float
-- will become unnecessary if outputGeneral is extended to apply to
-- DoubleFloat quantities.

)lib nrc
)lib nqip

outputGeneral 5

xvals := [0.00,0.04,0.08,0.12,0.22,0.26,0.30,0.38,0.39,0.42,0.45,
               0.46,0.60,0.68,0.72,0.73,0.83,0.85,0.88,0.90,1.00];

yvals := [4.0000,3.9936,3.9746,3.9432,3.8135,3.7467,3.6697,3.4943,
                 3.4719,3.4002,3.3264,3.3017,2.9412,2.7352,2.6344,
                        2.6094,2.3684,2.3222,2.2543,2.2099,2.0000];

result := nagPolygonIntegrate(xvals,yvals);
result.integral :: Float

--       3.1414

result.errorEstimate :: Float

--       - 0.000025627

coords := transpose matrix [xvals, yvals];
result := nagPolygonIntegrate coords;
result.integral :: Float

--       3.1414

result.errorEstimate :: Float

--       - 0.000025627

nagPolygonIntegrate([1,2,3],[1,2,3,4])

--   Error signalled from user code:
--      The lists supplied to nagPolygonIntegrate are of different
--      lengths: 3 and 4.

nagPolygonIntegrate([[1,2,3],[4,5,6]])

--   Error signalled from user code:
--      Please supply the coordinate matrix in nagPolygonIntegrate with
--      each row consisting of single a x-y pair.

outputGeneral()

output "End of tests"

#endif

@
\section{License}
<<license>>=
--Copyright (c) 1991-2002, The Numerical ALgorithms Group Ltd.
--All rights reserved.
--
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are
--met:
--
--    - Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--
--    - Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in
--      the documentation and/or other materials provided with the
--      distribution.
--
--    - Neither the name of The Numerical ALgorithms Group Ltd. nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
--
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
--IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
--TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
--PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
--OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
--EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
--PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
--PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
--LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
--NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
@
<<*>>=
<<license>>

-- NagQuadratureInterfacePackage

-- To test:
-- sed -ne '1,/^#if NeverAssertThis/d;/#endif/d;p' < nqip.as > nqip.input
-- axiom
-- )set nag host <some machine running nagd>
-- )r nqip.input

#unassert saturn

#include "axiom.as"

DF   ==> DoubleFloat ;
LDF  ==> List DoubleFloat ;
LLDF ==> List LDF ;
VDF  ==> Vector DoubleFloat ;
MDF  ==> Matrix DoubleFloat ;
INT  ==> Integer ;
RCD  ==> Record ;
RSLT ==> Result ;
STRG ==> String ;

<<NagQuadratureInterfacePackage>>
@
\eject
\begin{thebibliography}{99}
\bibitem{1} nothing
\end{thebibliography}
\end{document}
