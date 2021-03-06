\documentclass{article}
\usepackage{axiom}
\begin{document}
\title{\$SPAD/src/algebra axtimer.as}
\author{The Axiom Team}
\maketitle
\begin{abstract}
\end{abstract}
\eject
\tableofcontents
\eject
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

--------------------------------------------------------------------------------
--
-- BasicMath: timer.as --- Objects for tracking time
--
--------------------------------------------------------------------------------
--

-- ToDo: Write so that start!(x) ; start!(x) ; stop!(x); stop!(x) works.

#include "axiom.as"

Z ==> Integer;

Duration ==> Record(hours: Z, mins: Z, seconds: Z, milliseconds: Z);

+++ Timer
+++ History: 22/5/94 Original version by MB.
+++	      9/4/97 [Peter Broadbery] incorporated into Basicmath.
+++	      7/8/97 [PAB] Hacked into axiom.
+++ Timer is a type whose elements are stopwatch timers, which can be used
+++ to time precisely various sections of code.
+++ The precision can be up to 1 millisecond but depends on the operating system.
+++ The times returned are CPU times used by the process that created the timer.

Timer: BasicType with {
	HMS:    Z -> Duration;
		++ Returns (h, m, s, u) where n milliseconds is equal
		++ to h hours, m minutes, s seconds and u milliseconds.
	read:   %  -> Z;
		++ Reads the timer t without stopping it.
		++ Returns the total accumulated time in milliseconds by all
		++ the start/stop cycles since t was created or last reset.
		++ If t is running, the time since the last start is added in,
		++ and t is not stopped or affected.
	reset!: %  -> %;
		++ Resets the timer t to 0 and stops it if it is running.
		++Returns the timer t after it is reset.
	start!: %  -> Z;
		++ Starts or restarts t, without resetting it to 0,
		++ It has no effect on t if it is already running.
		++ Returns 0 if t was already running, the absolute time at which
		++ the start/restart was done otherwise.
	stop!:  %  -> Z;
		++ Stops t without resetting it to 0.
		++ It has no effect on t if it is not running.
		++ Returns the elapsed time in milliseconds since the last time t
		++ was restarted, 0 if t was not running.
	timer:  () -> %;
		++ Creates a timer, set to 0 and stopped.
		++ Returns the timer that has been created.

	coerce: % -> OutputForm;
#if 0
	gcTimer: () -> %;
		++ Returns the system garbage collection timer.
		++ Do not use for other purposes!
#endif
} == add {
        -- time     = total accumulated time since created or reset
        -- start    = absolute time of last start
        -- running? = true if currently running, false if currently stopped
	Rep ==> Record(time:Z, start:Z, running?:Boolean);
	import {
		BOOT_:_:GET_-INTERNAL_-RUN_-TIME: () -> Integer;
	} from Foreign Lisp;
	cpuTime(): Integer == BOOT_:_:GET_-INTERNAL_-RUN_-TIME();

	import from Rep, Z, Boolean;

	timer():% == per [0, 0, false];

	read(t:%):Z == {
		rec := rep t;
		ans := rec.time;
		if rec.running? then ans := ans + cpuTime() - rec.start;
		ans
	}

	stop!(t:%):Z == {
		local ans:Z;
		rec := rep t;
		if rec.running? then {
			ans := cpuTime() - rec.start;
			rec.time := rec.time + ans;
			rec.running? := false
		}
		else ans := 0;
		ans
	}

	start!(t:%):Z == {
		local ans:Z;
		rec := rep t;
		if not(rec.running?) then {
			rec.start := ans := cpuTime();
			rec.running? := true;
		}
		else ans := 0;
		ans
	}

	reset!(t:%):% == {
		rec := rep t;
		rec.time := rec.start := 0;
		rec.running? := false;
		t
	}

	HMS(m:Z): Duration == {
		import from Record(quotient: Integer, remainder: Integer);
		(h, m) := explode divide(m, 3600000);
		(m, s) := explode divide(m, 60000);
		(s, l) := explode divide(s, 1000);
		[h, m, s, l]
	}

#if 0
	import {
		gcTimer: () -> Pointer;
	} from Foreign C;

	gcTimer(): % == (gcTimer())@Pointer pretend %;
#endif
	coerce(x: %): OutputForm == {
		import from List OutputForm;
		assign(name: String, val: OutputForm): OutputForm == {
			import from Symbol;
			blankSeparate [outputForm(name::Symbol), outputForm("="::Symbol), val];
		}
		state: Symbol := coerce(if rep(x).running? then "on" else "off");
		bracket [outputForm("Timer:"::Symbol),
			 commaSeparate [assign("state", outputForm state),
				        assign("value", (read x)::OutputForm)]];
	}

	(a: %) = (b: %): Boolean == error "No equality for Timers";
}

@
\eject
\begin{thebibliography}{99}
\bibitem{1} nothing
\end{thebibliography}
\end{document}
