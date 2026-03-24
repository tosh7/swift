// RUN: %target-typecheck-verify-swift

protocol P {}
protocol Q {}
protocol R {}

struct ConcreteP: P {}
struct ConcretePQ: P, Q {}

// --- Basic case: Issue #61733 ---

func takeSomeP(_ x: (some P)?) {}

func test_basic_optional_existential() {
  let v: (any P)? = nil
  takeSomeP(v) // expected-error {{value of optional type '(any P)?' must be unwrapped to a value of type 'any P'}}
               // expected-note@-1 {{coalesce using '??' to provide a default when the optional value contains 'nil'}}
               // expected-note@-2 {{force-unwrap using '!' to abort execution if the optional value contains 'nil'}}
}

// --- Force-unwrap should compile ---

func test_force_unwrapped() {
  let v: (any P)? = ConcreteP()
  takeSomeP(v!) // OK
}

// --- Protocol mismatch: should NOT trigger the new diagnostic ---

func takeSomeR(_ x: (some R)?) {}

func test_protocol_mismatch() {
  let v: (any P)? = nil
  takeSomeR(v) // expected-error {{type 'any P' cannot conform to 'R'}}
               // expected-note@-1 {{only concrete types can conform to protocols}}
}

// --- Constrained generic parameter ---

func takeConstrained<T: P>(_ x: T?) {}

func test_constrained_generic() {
  let v: (any P)? = nil
  takeConstrained(v) // expected-error {{value of optional type '(any P)?' must be unwrapped to a value of type 'any P'}}
                     // expected-note@-1 {{coalesce using '??' to provide a default when the optional value contains 'nil'}}
                     // expected-note@-2 {{force-unwrap using '!' to abort execution if the optional value contains 'nil'}}
}

// --- Compound existential ---

func takeSomePQ(_ x: (some P & Q)?) {}

func test_compound_existential() {
  let v: (any P & Q)? = nil
  takeSomePQ(v) // expected-error {{value of optional type '(any P & Q)?' must be unwrapped to a value of type 'any P & Q'}}
                // expected-note@-1 {{coalesce using '??' to provide a default when the optional value contains 'nil'}}
                // expected-note@-2 {{force-unwrap using '!' to abort execution if the optional value contains 'nil'}}
}
