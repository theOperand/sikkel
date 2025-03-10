--------------------------------------------------
-- Proofs about the interactions between the different
-- modalities for guarded recursion
--------------------------------------------------

module Applications.GuardedRecursion.Model.Modalities.Interaction where

open import Data.Nat
open import Data.Unit
open import Function using (id; _∘_)
open import Relation.Binary.PropositionalEquality hiding ([_])

open import Model.BaseCategory
open import Model.CwF-Structure
open import Model.Modality
open import Applications.GuardedRecursion.Model.Modalities.Later
open import Applications.GuardedRecursion.Model.Modalities.Constantly
open import Applications.GuardedRecursion.Model.Modalities.Forever
open OmegaLimit
open import Applications.GuardedRecursion.Model.Modalities.Bundles


--------------------------------------------------
-- Interaction between the later and unit modalities

𝟙≤later : TwoCell 𝟙 later
transf-op (transf 𝟙≤later) = from-earlier
CtxNatTransf.naturality (transf 𝟙≤later) = from-earlier-natural


--------------------------------------------------
-- Interaction between the forever and later modalities

earlier-constantly-ctx : (Γ : Ctx ★) → ◄ (constantly-ctx Γ) ≅ᶜ constantly-ctx Γ
from (earlier-constantly-ctx Γ) = from-earlier (constantly-ctx Γ)
func (to (earlier-constantly-ctx Γ)) γ = γ
_⇒_.naturality (to (earlier-constantly-ctx Γ)) = refl
eq (isoˡ (earlier-constantly-ctx Γ)) _ = refl
eq (isoʳ (earlier-constantly-ctx Γ)) _ = refl

forever-later-tyʳ : {Γ : Ctx ★} (T : Ty (◄ (constantly-ctx Γ))) →
                    forever-ty (▻ T) ≅ᵗʸ forever-ty (T [ to (earlier-constantly-ctx Γ) ])
limit (func (from (forever-later-tyʳ T)) l) = λ n → limit l (suc n)
limit-natural (func (from (forever-later-tyʳ T)) l) m≤n = limit-natural l (s≤s m≤n)
_↣_.naturality (from (forever-later-tyʳ T)) = to-ω-limit-eq (λ _ → ty-cong T refl)
limit (func (to (forever-later-tyʳ T)) l) = λ { zero → _ ; (suc n) → limit l n }
limit-natural (func (to (forever-later-tyʳ T)) l) = λ { z≤n → refl ; (s≤s m≤n) → limit-natural l m≤n }
_↣_.naturality (to (forever-later-tyʳ T)) = to-ω-limit-eq (λ { zero → refl ; (suc n) → ty-cong T refl })
eq (isoˡ (forever-later-tyʳ T)) l = to-ω-limit-eq (λ { zero → refl ; (suc n) → refl })
eq (isoʳ (forever-later-tyʳ T)) l = to-ω-limit-eq (λ _ → refl)

forever-later : forever ⓜ later ≅ᵐ forever
eq-lock forever-later = earlier-constantly-ctx
eq (eq-lock-natural-to forever-later σ) δ = refl
eq-mod-tyʳ forever-later = forever-later-tyʳ

forever-later'-ty : {Γ : Ctx ★} (T : Ty (constantly-ctx Γ)) →
                    forever-ty (▻' T) ≅ᵗʸ forever-ty T
forever-later'-ty = eq-mod-tyˡ forever-later


--------------------------------------------------
-- Interaction between the forever and constantly modalities

now-constantly-ctx : (Γ : Ctx ★) → now (constantly-ctx Γ) ≅ᶜ Γ
func (from (now-constantly-ctx Γ)) = id
_⇒_.naturality (from (now-constantly-ctx Γ)) {f = tt} = ctx-id Γ
func (to (now-constantly-ctx Γ)) = id
_⇒_.naturality (to (now-constantly-ctx Γ)) {f = tt} = sym (ctx-id Γ)
eq (isoˡ (now-constantly-ctx Γ)) _ = refl
eq (isoʳ (now-constantly-ctx Γ)) _ = refl

now-constantly-natural : {Δ : Ctx ★} {Γ : Ctx ★} (σ : Δ ⇒ Γ) →
                         from (now-constantly-ctx Γ) ⊚ now-subst (constantly-subst σ) ≅ˢ σ ⊚ from (now-constantly-ctx Δ)
eq (now-constantly-natural σ) _ = refl

forever-constantly-tyʳ : {Γ : Ctx ★} (T : Ty (now (constantly-ctx Γ))) →
                         forever-ty (constantly-ty T) ≅ᵗʸ T [ to (now-constantly-ctx Γ) ]
func (from (forever-constantly-tyʳ T)) l = limit l 0
_↣_.naturality (from (forever-constantly-tyʳ T)) = ty-cong T refl
limit (func (to (forever-constantly-tyʳ T)) t) = λ n → t
limit-natural (func (to (forever-constantly-tyʳ T)) t) = λ m≤n → ty-id T
_↣_.naturality (to (forever-constantly-tyʳ T)) = to-ω-limit-eq (λ _ → ty-cong T refl)
eq (isoˡ (forever-constantly-tyʳ T)) l = to-ω-limit-eq (λ _ → trans (sym (limit-natural l z≤n)) (ty-id T))
eq (isoʳ (forever-constantly-tyʳ T)) _ = refl

forever-constantly : forever ⓜ constantly ≅ᵐ 𝟙
eq-lock forever-constantly = now-constantly-ctx
eq (eq-lock-natural-to forever-constantly σ) δ = refl
eq-mod-tyʳ forever-constantly = forever-constantly-tyʳ

now-constantly-ctx-intro : {A : ClosedTy ★} {{_ : IsClosedNatural A}} {Γ : Ctx ★} →
                           Tm Γ A → Tm (now (constantly-ctx Γ)) A
now-constantly-ctx-intro {A} t = unconstantly-tm (unforever-tm (ι[ eq-mod-closed forever-constantly A ] t))

to-constantly-now-ctx : (Γ : Ctx ω) → (Γ ⇒ constantly-ctx (now Γ))
func (to-constantly-now-ctx Γ) = Γ ⟪ z≤n ⟫_
_⇒_.naturality (to-constantly-now-ctx Γ) = ctx-comp Γ

to-constantly-now-ctx-natural : {Δ Γ : Ctx ω} (σ : Δ ⇒ Γ) →
    to-constantly-now-ctx Γ ⊚ σ ≅ˢ ctx-fmap (constantly-ctx-functor ⓕ now-functor) σ ⊚ to-constantly-now-ctx Δ
eq (to-constantly-now-ctx-natural σ) δ = _⇒_.naturality σ

constantly∘forever≤𝟙 : TwoCell (constantly ⓜ forever) 𝟙
transf-op (transf constantly∘forever≤𝟙) = to-constantly-now-ctx
CtxNatTransf.naturality (transf constantly∘forever≤𝟙) = to-constantly-now-ctx-natural

from-constantly-forever-ty : {Γ : Ctx ω} {T : Ty (constantly-ctx (now Γ))} →
                             Tm Γ (constantly-ty (forever-ty T)) → Tm Γ (T [ to-constantly-now-ctx Γ ])
from-constantly-forever-ty {Γ = Γ} t = unforever-tm (unconstantly-tm t) [ to-constantly-now-ctx Γ ]'
