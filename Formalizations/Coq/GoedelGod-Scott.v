(* Formalization of Goedel's Ontological Proof of God's Existence *)

(* Authors: Bruno Woltzenlogel Paleo (bruno@logic.at) and Christoph Benzmueller *)

(* This formalization aims at *)
(* being as similar as possible to Dana Scott's version of the proof *)

(* The numbering of axioms, definitions and theorems is exactly the same as in Scott's notes *)

(* The formal proofs follow the same structure of Scott's proof sketches and fill their gaps *)
(* Whenever a 'cut' or 'assert' uses a lemma mentioned in Scott's sketches, *) 
(* this is emphasized with a comment *)



Require Import Coq.Logic.Classical.
Require Import Coq.Logic.Classical_Pred_Type.

Require Import Modal.
Require Import ModalClassical.


Ltac proof_by_contradiction H := apply NNPP; intro H.


(* Constant predicate that distinguishes positive properties *)
Parameter Positive: (u -> o) -> o.


(* Axiom A1: either a property or its negation is positive, but not both *)
Axiom axiom1a : V (mforall p, (Positive (fun x: u => m~(p x))) m-> (m~ (Positive p))).
Axiom axiom1b : V (mforall p, (m~ (Positive p)) m-> (Positive (fun x: u => m~ (p x))) ).


(* Axiom A2: a property necessarily implied by a positive property is positive *)
Axiom axiom2: V (mforall p, mforall q, Positive p m/\ (box (mforall x, (p x) m-> (q x) )) m-> Positive q).


(* ToDo: Add explicit names to assertions *)

(* ToDo: Use only asserts for real cuts *)

(* Theorem T1: positive properties are possibly exemplified *)
Theorem theorem1: V (mforall p, (Positive p) m-> dia (mexists x, p x) ).
Proof.
intro w.
intro p.
intro H1.
proof_by_contradiction H2.
apply not_dia_box_not in H2.
assert ((box (mforall x, m~ (p x))) w). (* Lemma from Scott's notes *)
  intro w1; intro R1.
  unfold box in H2.
  intro x.
  assert ((m~ (mexists x : u, p x)) w1).
    apply (H2 w1 R1).

    clear H2 R1 H1 w.
    intro H3.
    apply H.
    exists x.
    exact H3.

  assert ((box (mforall x, (p x) m-> m~ (x m= x))) w). (* Lemma from Scott's notes *)    
    intro w1; intro R1.
    intro x.
    intro H3.
    intro H4.
    apply (H w1 R1 x).
    exact H3.

    assert ((Positive (fun x => m~ (x m= x))) w). (* Lemma from Scott's notes *)
    apply (axiom2 w p (fun x => m~ (x m= x))).
    split.
      exact H1.

      exact H0.
    assert ((box (mforall x, (p x) m-> (x m= x))) w). (* Lemma from Scott's notes *)
      intros w1 R1 x H4.     
      reflexivity.

      assert (H5 : ((Positive (fun x => (x m= x))) w)). (* Lemma from Scott's notes *)
        apply (axiom2 w p (fun x => x m= x )).
        split.
          exact H1.

          exact H4.

        clear H1 H2 H H0 H4 p.
        apply axiom1a in H3.
        contradiction.
Qed.


(* Definition D1: God: a God-like being possesses all positive properties *)
Definition G(x: u) := mforall p, (Positive p) m-> (p x).


(* Axiom A3: the property of being God-like is positive *)
Axiom axiom3: V (Positive G).


(* Corollary C1: possibly, God exists *)
Theorem corollary1: V (dia (mexists x, G x)). 
Proof.
intro w. 
apply theorem1.
apply axiom3.
Qed.


(* Axiom A4: positive properties are necessarily positive *)
Axiom axiom4: V (mforall p, (Positive p) m-> box (Positive p)).


(* Definition D2: essence: an essence of an individual is a property possessed by it and necessarily implying any of its properties *)
Definition Essence(p: u -> o)(x: u) := (p x) m/\ mforall q, ((q x) m-> box (mforall y, (p y) m-> (q y))).
Notation "p 'ess' x" := (Essence p x) (at level 69).


(* Theorem T2: being God-like is an essence of any God-like being *)
Theorem theorem2: V (mforall x, (G x) m-> (G ess x)).
Proof.
intro.
intro g.
intro H1.
unfold Essence.
split.
  exact H1.

  intro q.
  intro H2.
  cut (box (Positive q) w). (* Lemma from Scott's notes *)
    apply K.
    intros w1 R1.
    intro H3.
    intro y.
    intro H4.
    unfold G in H4.
    apply (H4 q).
    exact H3.

    apply axiom4.
    unfold G in H1.             (* ToDo: This proof by contradiction could be moved to the beginning with an assert *)
    proof_by_contradiction H5.  (* Scott's proof of (Positive q) by contradiction *) 
    apply axiom1b in H5.
    apply H1 in H5.
    contradiction.
Qed.

(* ToDo: in Scotts notes there are two notes that do not seem important for the proof, but would be interesting to formalize anyway *)

(* Definition D3: necessary existence: necessary existence of an individual is the necessary exemplification of all its essences *)
Definition NE(x: u) := mforall p, (p ess x) m-> box (mexists y, (p y)).


(* Axiom A5: necessary existence is a positive property *)
Axiom axiom5: V (Positive NE).


Lemma lemma1: V ((mexists z, (G z)) m-> box (mexists x, (G x))).
Proof.
intro w.
intro H1.
destruct H1 as [g H2].
cut ((G ess g) w).      (* Lemma from Scott's notes *)
  cut (NE g w).       (* Lemma from Scott's notes *)
    intro H3.
    unfold NE in H3.
    apply H3.

    cut (Positive NE w).
      unfold G in H2.
      apply H2.

      apply axiom5.

  cut (G g w).
    apply theorem2.

    exact H2.
Qed.


Lemma lemma2: V (dia (mexists z, (G z)) m-> box (mexists x, (G x))).
Proof.
intro w.
intro H.
cut (dia (box (mexists x, G x)) w).  (* Lemma from Scott's notes *)
  apply dia_box_to_box.

  apply (modus_ponens_inside_dia w (mexists z, G z)).
    exact H.
       
    intros w1 R1.
    apply lemma1.
Qed.


(* Theorem T3: necessarily, a God exists *)
Theorem theorem3: V (box (mexists x, (G x))).
Proof.
intro w.
apply lemma2.
apply corollary1.
Qed.


(* Corollary C2: There exists a god *)
Theorem corollary2: V (mexists x, (G x)).
Proof.
intro.
apply T.
apply theorem3.
Qed.