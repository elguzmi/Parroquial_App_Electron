const SETUP_DRAFT_KEY = "parroquia_setup_draft";

export function loadSetupDraft() {
  try {
    const raw = sessionStorage.getItem(SETUP_DRAFT_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch (_) {
    return null;
  }
}

export function saveSetupDraft(partial) {
  const current = loadSetupDraft() || {};
  const next = { ...current, ...partial, updatedAt: Date.now() };
  sessionStorage.setItem(SETUP_DRAFT_KEY, JSON.stringify(next));
  return next;
}

export function clearSetupDraft() {
  sessionStorage.removeItem(SETUP_DRAFT_KEY);
}

export function hasSqlDraft() {
  const draft = loadSetupDraft();
  return Boolean(
    draft?.sql?.server &&
      draft?.sql?.database &&
      draft?.sql?.user &&
      draft?.sql?.password != null &&
      draft?.sqlVerified
  );
}
