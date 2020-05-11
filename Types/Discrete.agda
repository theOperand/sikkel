module Types.Discrete where

open import Data.Bool using (Bool; true; false; if_then_else_)
open import Data.Nat hiding (_⊔_)
open import Data.Nat.Properties
open import Data.Unit using (⊤; tt)
open import Function hiding (_⟨_⟩_)
open import Level renaming (zero to lzero; suc to lsuc)
open import Relation.Binary.PropositionalEquality hiding ([_]; naturality; Extensionality)

open import Helpers
open import CwF-Structure.Contexts
open import CwF-Structure.Types
open import CwF-Structure.Terms
open import CwF-Structure.SubstitutionSequence

--------------------------------------------------
-- Discrete types
--------------------------------------------------

Discr-prim : (A : Set 0ℓ) → Ty (◇ {0ℓ})
type (Discr-prim A) _ _ = A
morph (Discr-prim A) _ _ = id
morph-id (Discr-prim A) _ = refl
morph-comp (Discr-prim A) _ _ _ _ _ = refl

Discr : (A : Set 0ℓ) {Γ : Ctx 0ℓ} → Ty Γ
Discr A {Γ} = Discr-prim A [ !◇ Γ ]

discr : {A : Set 0ℓ} {Γ : Ctx 0ℓ} → A → Tm Γ (Discr A)
term (discr a) _ _ = a
naturality (discr a) _ _ = refl

undiscr : {A : Set 0ℓ} → Tm ◇ (Discr A) → A
undiscr t = t ⟨ 0 , lift tt ⟩'

undiscr-discr : {A : Set 0ℓ} (a : A) → undiscr (discr a) ≡ a
undiscr-discr a = refl

discr-undiscr : {A : Set 0ℓ} (t : Tm ◇ (Discr A)) → discr (undiscr t) ≅ᵗᵐ t
eq (discr-undiscr t) _ = sym (naturality t z≤n refl)

Discr-subst : (A : Set 0ℓ) {Δ Γ : Ctx 0ℓ} (σ : Δ ⇒ Γ) → Discr A [ σ ] ≅ᵗʸ Discr A
from (Discr-subst A σ) = record { func = id ; naturality = λ _ → refl }
to (Discr-subst A σ) = record { func = id ; naturality = λ _ → refl }
eq (isoˡ (Discr-subst A σ)) _ = refl
eq (isoʳ (Discr-subst A σ)) _ = refl

discr-subst : {A : Set 0ℓ} (a : A) {Δ Γ : Ctx 0ℓ} (σ : Δ ⇒ Γ) → (discr a) [ σ ]' ≅ᵗᵐ ι[ Discr-subst A σ ] (discr a)
eq (discr-subst a σ) _ = refl

Unit' : {Γ : Ctx 0ℓ} → Ty Γ
Unit' = Discr ⊤

tt' : {Γ : Ctx 0ℓ} → Tm Γ Unit'
tt' = discr tt

Bool' : {Γ : Ctx 0ℓ} → Ty Γ
Bool' = Discr Bool

true' : {Γ : Ctx 0ℓ} → Tm Γ Bool'
true' = discr true

false' : {Γ : Ctx 0ℓ} → Tm Γ Bool'
false' = discr false

if'_then'_else'_ : {Γ : Ctx 0ℓ} {T : Ty Γ} → Tm Γ Bool' → Tm Γ T → Tm Γ T → Tm Γ T
term (if' c then' t else' f) = λ n γ → if c ⟨ n , γ ⟩' then t ⟨ n , γ ⟩' else f ⟨ n , γ ⟩'
naturality (if'_then'_else'_ {Γ = Γ} c t f) {m} {n} ineq {γ} {γ'} eγ with c ⟨ m , γ' ⟩' | c ⟨ n , γ ⟩' | naturality c ineq eγ
naturality (if'_then'_else'_ {Γ} c t f) {m} {n} ineq {γ} {γ'} eγ | false | .false | refl = naturality f ineq eγ
naturality (if'_then'_else'_ {Γ} c t f) {m} {n} ineq {γ} {γ'} eγ | true  | .true  | refl = naturality t ineq eγ

β-Bool'-true : {Γ : Ctx 0ℓ} {T : Ty Γ} (t t' : Tm Γ T) →
               if' true' then' t else' t' ≅ᵗᵐ t
β-Bool'-true t t' = ≅ᵗᵐ-refl

β-Bool'-false : {Γ : Ctx 0ℓ} {T : Ty Γ} (t t' : Tm Γ T) →
               if' false' then' t else' t' ≅ᵗᵐ t'
β-Bool'-false t t' = ≅ᵗᵐ-refl

Nat' : {Γ : Ctx 0ℓ} → Ty Γ
Nat' = Discr ℕ

zero' : {Γ : Ctx 0ℓ} → Tm Γ Nat'
zero' = discr zero

suc' : {Γ : Ctx 0ℓ} → Tm Γ Nat' → Tm Γ Nat'
term (suc' t) = λ n γ → suc (t ⟨ n , γ ⟩')
naturality (suc' t) = λ m≤n γ → cong suc (naturality t m≤n γ)
