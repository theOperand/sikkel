--------------------------------------------------
-- Contexts and substitutions + category structure
--------------------------------------------------

module CwF-Structure.Contexts where

-- open import Data.Nat hiding (_⊔_)
-- open import Data.Nat.Properties
open import Data.Unit using (⊤; tt)
open import Function hiding (_⟨_⟩_)
open import Level renaming (zero to lzero; suc to lsuc)
open import Relation.Binary.PropositionalEquality hiding ([_]; naturality; Extensionality; subst₂)

open import Categories
open import Helpers


--------------------------------------------------
-- Definition of contexts and substitutions

record Ctx (C : Category) ℓ : Set (lsuc ℓ) where
  constructor MkCtx

  open Category C

  field
    set : Ob → Set ℓ
    rel : ∀ {x y} → Hom x y → set y → set x
    rel-id : ∀ {x} (γ : set x) → rel hom-id γ ≡ γ
    rel-comp : ∀ {x y z} (f : Hom x y) (g : Hom y z) (γ : set z) → rel (g ∙ f) γ ≡ rel f (rel g γ)
open Ctx public

module _ {C : Category} where
  infix 10 _⇒_
  infix 1 _≅ˢ_ _≅ᶜ_
  infixl 20 _⊚_

  open Category C

  private
    variable
      x y z : Ob

  _⟨_⟩ : Ctx C ℓ → Ob → Set ℓ
  Γ ⟨ x ⟩ = set Γ x

  _⟪_⟫ : (Γ : Ctx C ℓ) (f : Hom x y) → Γ ⟨ y ⟩ → Γ ⟨ x ⟩
  Γ ⟪ f ⟫ = rel Γ f

  _⟪_⟫_ : (Γ : Ctx C ℓ) (f : Hom x y) → Γ ⟨ y ⟩ → Γ ⟨ x ⟩
  Γ ⟪ f ⟫ γ = (Γ ⟪ f ⟫) γ

  -- The following proof is needed to define composition of morphisms in the category of elements
  -- of Γ and is used e.g. in the definition of types (in general) and function types.
  strong-rel-comp : (Γ : Ctx C ℓ) {f : Hom x y} {g : Hom y z} {γz : Γ ⟨ z ⟩} {γy : Γ ⟨ y ⟩} {γx : Γ ⟨ x ⟩} →
                    (eq-zy : Γ ⟪ g ⟫ γz ≡ γy) (eq-yx : Γ ⟪ f ⟫ γy ≡ γx) →
                    Γ ⟪ g ∙ f ⟫ γz ≡ γx
  strong-rel-comp Γ {f}{g}{γz} eq-zy eq-yx = trans (rel-comp Γ f g γz)
                                                   (trans (cong (Γ ⟪ f ⟫) eq-zy)
                                                          eq-yx)

  record _⇒_ {ℓ} (Δ Γ : Ctx C ℓ) : Set ℓ where
    constructor MkSubst
    field
      func : ∀ {x} → Δ ⟨ x ⟩ → Γ ⟨ x ⟩
      naturality : ∀ {x y} {f : Hom x y} (δ : Δ ⟨ y ⟩) → Γ ⟪ f ⟫ (func δ) ≡ func (Δ ⟪ f ⟫ δ)
  open _⇒_ public

  id-subst : (Γ : Ctx C ℓ) → Γ ⇒ Γ
  func (id-subst Γ) = id
  naturality (id-subst Γ) = λ _ → refl

  _⊚_ : {Δ Γ Θ : Ctx C ℓ} → Γ ⇒ Θ → Δ ⇒ Γ → Δ ⇒ Θ
  func (τ ⊚ σ) = func τ ∘ func σ
  naturality (_⊚_ τ σ) δ = trans (naturality τ (func σ δ))
                                  (cong (func τ) (naturality σ δ))
  {-
  More detailed version of the above naturality proof. We do not use this as it inserts
  refl at the end (and trans eq refl is not definitionally equal to eq).
    Θ ⟪ m≤n ⟫ (func τ (func σ δ)) ≡⟨ naturality τ (func σ δ) ⟩
    func τ (Γ ⟪ m≤n ⟫ func σ δ)   ≡⟨ cong (func τ) (naturality σ δ) ⟩
    func τ (func σ (Δ ⟪ m≤n ⟫ δ)) ∎
    where open ≡-Reasoning
  -}


  --------------------------------------------------
  -- Equivalence of substitutions

  record _≅ˢ_ {ℓ} {Δ Γ : Ctx C ℓ} (σ τ : Δ ⇒ Γ) : Set ℓ where
    field
      eq : ∀ {x} δ → func σ {x} δ ≡ func τ δ
  open _≅ˢ_ public

  ≅ˢ-refl : {Δ Γ : Ctx C ℓ} {σ : Δ ⇒ Γ} → σ ≅ˢ σ
  eq (≅ˢ-refl {σ = σ}) _ = refl

  ≅ˢ-sym : {Δ Γ : Ctx C ℓ} {σ τ : Δ ⇒ Γ} → σ ≅ˢ τ → τ ≅ˢ σ
  eq (≅ˢ-sym σ=τ) δ = sym (eq σ=τ δ)

  ≅ˢ-trans : {Δ Γ : Ctx C ℓ} {σ τ ψ : Δ ⇒ Γ} → σ ≅ˢ τ → τ ≅ˢ ψ → σ ≅ˢ ψ
  eq (≅ˢ-trans σ=τ τ=ψ) δ = trans (eq σ=τ δ) (eq τ=ψ δ)

  module ≅ˢ-Reasoning {Δ Γ : Ctx C ℓ} where
    infix  3 _∎
    infixr 2 _≅⟨⟩_ step-≅ step-≅˘
    infix  1 begin_

    begin_ : ∀ {σ τ : Δ ⇒ Γ} → σ ≅ˢ τ → σ ≅ˢ τ
    begin_ σ=τ = σ=τ

    _≅⟨⟩_ : ∀ (σ {τ} : Δ ⇒ Γ) → σ ≅ˢ τ → σ ≅ˢ τ
    _ ≅⟨⟩ σ=τ = σ=τ

    step-≅ : ∀ (σ {τ ψ} : Δ ⇒ Γ) → τ ≅ˢ ψ → σ ≅ˢ τ → σ ≅ˢ ψ
    step-≅ _ τ≅ψ σ≅τ = ≅ˢ-trans σ≅τ τ≅ψ

    step-≅˘ : ∀ (σ {τ ψ} : Δ ⇒ Γ) → τ ≅ˢ ψ → τ ≅ˢ σ → σ ≅ˢ ψ
    step-≅˘ _ τ≅ψ τ≅σ = ≅ˢ-trans (≅ˢ-sym τ≅σ) τ≅ψ

    _∎ : ∀ (σ : Δ ⇒ Γ) → σ ≅ˢ σ
    _∎ _ = ≅ˢ-refl

    syntax step-≅  σ τ≅ψ σ≅τ = σ ≅⟨  σ≅τ ⟩ τ≅ψ
    syntax step-≅˘ σ τ≅ψ τ≅σ = σ ≅˘⟨ τ≅σ ⟩ τ≅ψ


  --------------------------------------------------
  -- Laws for the category of contexts

  ⊚-id-substʳ : {Δ Γ : Ctx C ℓ} (σ : Δ ⇒ Γ) → σ ⊚ id-subst Δ ≅ˢ σ
  eq (⊚-id-substʳ σ) _ = refl

  ⊚-id-substˡ : {Δ Γ : Ctx C ℓ} (σ : Δ ⇒ Γ) → id-subst Γ ⊚ σ ≅ˢ σ
  eq (⊚-id-substˡ σ) _ = refl

  ⊚-assoc : {Γ₁ Γ₂ Γ₃ Γ₄ : Ctx C ℓ} (σ₃₄ : Γ₃ ⇒ Γ₄) (σ₂₃ : Γ₂ ⇒ Γ₃) (σ₁₂ : Γ₁ ⇒ Γ₂) → (σ₃₄ ⊚ σ₂₃) ⊚ σ₁₂ ≅ˢ σ₃₄ ⊚ (σ₂₃ ⊚ σ₁₂)
  eq (⊚-assoc σ₃₄ σ₂₃ σ₁₂) _ = refl

  ⊚-congˡ : {Δ Γ Θ : Ctx C ℓ} (τ : Γ ⇒ Θ) {σ σ' : Δ ⇒ Γ} → σ ≅ˢ σ' → τ ⊚ σ ≅ˢ τ ⊚ σ'
  eq (⊚-congˡ τ σ=σ') δ = cong (func τ) (eq σ=σ' δ)

  ⊚-congʳ : {Δ Γ Θ : Ctx C ℓ} {τ τ' : Γ ⇒ Θ} (σ : Δ ⇒ Γ) → τ ≅ˢ τ' → τ ⊚ σ ≅ˢ τ' ⊚ σ
  eq (⊚-congʳ σ τ=τ') δ = eq τ=τ' (func σ δ)


  --------------------------------------------------
  -- Equivalence of contexts

  record _≅ᶜ_ {ℓ} (Δ Γ : Ctx C ℓ) : Set ℓ where
    field
      from : Δ ⇒ Γ
      to : Γ ⇒ Δ
      isoˡ : to ⊚ from ≅ˢ id-subst Δ
      isoʳ : from ⊚ to ≅ˢ id-subst Γ
  open _≅ᶜ_ public

  ≅ᶜ-refl : {Γ : Ctx C ℓ} → Γ ≅ᶜ Γ
  from (≅ᶜ-refl {Γ = Γ}) = id-subst Γ
  to (≅ᶜ-refl {Γ = Γ}) = id-subst Γ
  isoˡ (≅ᶜ-refl {Γ = Γ}) = ≅ˢ-refl
  isoʳ (≅ᶜ-refl {Γ = Γ}) = ≅ˢ-refl

  ≅ᶜ-sym : {Δ Γ : Ctx C ℓ} → Δ ≅ᶜ Γ → Γ ≅ᶜ Δ
  from (≅ᶜ-sym Δ=Γ) = to Δ=Γ
  to (≅ᶜ-sym Δ=Γ) = from Δ=Γ
  isoˡ (≅ᶜ-sym Δ=Γ) = isoʳ Δ=Γ
  isoʳ (≅ᶜ-sym Δ=Γ) = isoˡ Δ=Γ

  ≅ᶜ-trans : {Δ Γ Θ : Ctx C ℓ} → Δ ≅ᶜ Γ → Γ ≅ᶜ Θ → Δ ≅ᶜ Θ
  from (≅ᶜ-trans Δ=Γ Γ=Θ) = from Γ=Θ ⊚ from Δ=Γ
  to (≅ᶜ-trans Δ=Γ Γ=Θ) = to Δ=Γ ⊚ to Γ=Θ
  isoˡ (≅ᶜ-trans Δ=Γ Γ=Θ) =
    begin
      (to Δ=Γ ⊚ to Γ=Θ) ⊚ (from Γ=Θ ⊚ from Δ=Γ)
    ≅⟨ ⊚-assoc (to Δ=Γ) (to Γ=Θ) _ ⟩
      to Δ=Γ ⊚ (to Γ=Θ ⊚ (from Γ=Θ ⊚ from Δ=Γ))
    ≅˘⟨ ⊚-congˡ (to Δ=Γ) (⊚-assoc (to Γ=Θ) (from Γ=Θ) (from Δ=Γ)) ⟩
      to Δ=Γ ⊚ ((to Γ=Θ ⊚ from Γ=Θ) ⊚ from Δ=Γ)
    ≅⟨ ⊚-congˡ (to Δ=Γ) (⊚-congʳ (from Δ=Γ) (isoˡ Γ=Θ)) ⟩
      to Δ=Γ ⊚ (id-subst _ ⊚ from Δ=Γ)
    ≅⟨ ⊚-congˡ (to Δ=Γ) (⊚-id-substˡ (from Δ=Γ)) ⟩
      to Δ=Γ ⊚ from Δ=Γ
    ≅⟨ isoˡ Δ=Γ ⟩
      id-subst _ ∎
    where open ≅ˢ-Reasoning
  isoʳ (≅ᶜ-trans Δ=Γ Γ=Θ) =
    begin
      (from Γ=Θ ⊚ from Δ=Γ) ⊚ (to Δ=Γ ⊚ to Γ=Θ)
    ≅⟨ ⊚-assoc (from Γ=Θ) (from Δ=Γ) _ ⟩
      from Γ=Θ ⊚ (from Δ=Γ ⊚ (to Δ=Γ ⊚ to Γ=Θ))
    ≅˘⟨ ⊚-congˡ (from Γ=Θ) (⊚-assoc (from Δ=Γ) (to Δ=Γ) (to Γ=Θ)) ⟩
      from Γ=Θ ⊚ ((from Δ=Γ ⊚ to Δ=Γ) ⊚ to Γ=Θ)
    ≅⟨ ⊚-congˡ (from Γ=Θ) (⊚-congʳ (to Γ=Θ) (isoʳ Δ=Γ)) ⟩
      from Γ=Θ ⊚ (id-subst _ ⊚ to Γ=Θ)
    ≅⟨ ⊚-congˡ (from Γ=Θ) (⊚-id-substˡ (to Γ=Θ)) ⟩
      from Γ=Θ ⊚ to Γ=Θ
    ≅⟨ isoʳ Γ=Θ ⟩
      id-subst _ ∎
    where open ≅ˢ-Reasoning


  --------------------------------------------------
  -- The empty context (i.e. terminal object)

  ◇ : Ctx C ℓ
  set ◇ _ = Lift _ ⊤
  rel ◇ _ _ = lift tt
  rel-id ◇ _ = refl
  rel-comp ◇ _ _ _ = refl

  !◇ : (Γ : Ctx C ℓ) → Γ ⇒ ◇
  func (!◇ Γ) _ = lift tt
  naturality (!◇ Γ) _ = refl

  ◇-terminal : (Γ : Ctx C ℓ) (σ τ : Γ ⇒ ◇) → σ ≅ˢ τ
  eq (◇-terminal Γ σ τ) _ = refl
