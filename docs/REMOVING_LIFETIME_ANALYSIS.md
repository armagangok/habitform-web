# Analysis: Removing Lifetime from App Store Connect

## Summary

**Removing the Lifetime product from App Store Connect will not cause a crash** in the current codebase. The app does not hardcode the Lifetime product and works off RevenueCat offerings and entitlement status.

---

## 1. No Hardcoded "Lifetime" Reference

- There is **no** string or product ID for "Lifetime" in the Dart code.
- Packages are taken from **RevenueCat**: `state.offerings?.current?.availablePackages`.
- The paywall builds the list dynamically from whatever packages RevenueCat returns.

So removing Lifetime only reduces the set of products; the UI still renders whatever is in `availablePackages`.

---

## 2. Subscription Status Is Entitlement-Based

- Pro status is determined by **entitlement**, not by product ID:
  - `customerInfo.entitlements.active.isNotEmpty`
  - Entitlement ID: `HabitRisePro` (see `lib/features/purchase/constants/constants.dart`).
- The app does not check *which* product (monthly, annual, lifetime) unlocked the entitlement.
- **Existing Lifetime subscribers** keep their active entitlement; they continue to be Pro. No code path depends on the Lifetime product still existing in the store.

---

## 3. Paywall Package List

- The paywall iterates over `availablePackages` with `asMap().entries.map(...)`.
- If you remove Lifetime from App Store Connect (and from the RevenueCat offering), RevenueCat will typically return only the remaining packages (e.g. monthly + annual).
- The list is built from that list; no fixed indices are used for rendering the list itself, so **no crash** from removing one package.

---

## 4. Discount Calculation (Only Place Using Fixed Indices)

In `paywall_page.dart` around lines 829–834:

- Discount is shown when `availablePackages.length > 1 && index == 1`.
- It uses `availablePackages.first` as “monthly” and `availablePackages[1]` as “annual”.
- **Crash risk:** Only if `availablePackages.length` were 1 would index `1` be invalid, but the condition `availablePackages.length > 1` prevents accessing `availablePackages[1]` in that case. So **no crash** when only Lifetime is removed and monthly + annual remain.
- **Behavior note:** The logic assumes package at index 0 is monthly and index 1 is annual. If RevenueCat returns them in a different order (e.g. annual first), the discount percentage could be wrong, but the app still won’t crash.

A small improvement is to derive “monthly” and “annual” by product identifier instead of by index, so the discount stays correct regardless of package order (see code change below).

---

## 5. Default Selected Package

- Default selection uses a loop to find a package whose identifier contains `year` / `annual` / `yearly`, or falls back to index 0.
- `selectedIndex` is clamped to `0 .. availablePackages.length - 1`.
- With only monthly and annual, this remains valid; **no crash**.

---

## 6. Other References

- `getActivePackage()` uses `offerings.current?.monthly ?? offerings.current?.annual`. It does not reference a lifetime package type. No crash.
- `PurchaseService` and `PurchaseNotifier` work with generic `Package` and `CustomerInfo`; no dependency on Lifetime.

---

## 7. What You Should Do

1. **App Store Connect**  
   Remove or retire the Lifetime in-app purchase as planned. The app will not crash.

2. **RevenueCat**  
   Update your RevenueCat “Current” offering so it no longer includes the Lifetime product. That way users won’t see an unavailable product and won’t attempt a purchase that can’t complete.

3. **Existing Lifetime buyers**  
   They keep their entitlement; no code change needed for them to stay Pro.

4. **Optional code improvement**  
   Make the paywall discount logic robust to package order by resolving monthly and annual by identifier (see below).

---

## Optional: Safer Discount Calculation

The following helper finds monthly and annual packages by identifier so the discount is correct regardless of order. You can add it and use it in `_productSection` where the discount is computed.

```dart
// Add to _PaywallWidgetState. Use when availablePackages.length > 1 to compute discount.
Package? _findPackageByIdentifier(List<Package> packages, List<String> keywords) {
  final lower = packages.map((p) => p.storeProduct.identifier.toLowerCase()).toList();
  for (final kw in keywords) {
    final i = lower.indexWhere((id) => id.contains(kw));
    if (i >= 0) return packages[i];
  }
  return null;
}
// Then: find monthly (e.g. 'month','monthly') and annual ('year','annual','yearly'),
// compute discount only when both are present, using their prices.
```

This avoids relying on `availablePackages.first` and `availablePackages[1]` as “monthly” and “annual”.
