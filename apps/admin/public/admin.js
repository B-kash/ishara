const sessionStorageKey = "isharaAdminSession";

const loginPanel = document.getElementById("login-panel");
const adminPanel = document.getElementById("admin-panel");
const loginForm = document.getElementById("login-form");
const loginError = document.getElementById("login-error");
const signedInLabel = document.getElementById("signed-in-label");
const logoutButton = document.getElementById("logout-button");
const addSignForm = document.getElementById("add-sign-form");
const addSignMessage = document.getElementById("add-sign-message");
const bulkImportForm = document.getElementById("bulk-import-form");
const bulkImportResult = document.getElementById("bulk-import-result");
const categoryOptions = document.getElementById("category-options");
const tabButtons = document.querySelectorAll(".tab-button");
const tabPanels = document.querySelectorAll(".tab-panel");

function readStoredSession() {
  const rawSession = window.localStorage.getItem(sessionStorageKey);
  if (!rawSession) {
    return null;
  }

  try {
    return JSON.parse(rawSession);
  } catch {
    window.localStorage.removeItem(sessionStorageKey);
    return null;
  }
}

function storeSession(session) {
  window.localStorage.setItem(sessionStorageKey, JSON.stringify(session));
}

function clearSession() {
  window.localStorage.removeItem(sessionStorageKey);
}

function getAuthToken() {
  return readStoredSession()?.token ?? null;
}

function showLogin(message = "") {
  adminPanel.hidden = true;
  loginPanel.hidden = false;
  loginError.hidden = !message;
  loginError.textContent = message;
}

function showAdmin(session) {
  loginPanel.hidden = true;
  adminPanel.hidden = false;
  signedInLabel.textContent = `Signed in as ${session.username}`;
}

async function apiRequest(path, options = {}) {
  const headers = new Headers(options.headers ?? {});
  const token = getAuthToken();

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  if (options.body && !(options.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }

  const response = await fetch(path, {
    ...options,
    headers,
  });

  const responseText = await response.text();
  let responseBody = null;

  if (responseText) {
    try {
      responseBody = JSON.parse(responseText);
    } catch {
      responseBody = { message: responseText };
    }
  }

  if (response.status === 401) {
    clearSession();
    showLogin("Session expired. Please sign in again.");
    throw new Error("Unauthorized");
  }

  if (!response.ok) {
    const errorMessage =
      responseBody?.error?.message ??
      responseBody?.message ??
      `Request failed (${response.status})`;
    throw new Error(errorMessage);
  }

  return responseBody;
}

async function verifyExistingSession() {
  const session = readStoredSession();
  if (!session?.token) {
    showLogin();
    return;
  }

  try {
    await apiRequest("/admin/session");
    showAdmin(session);
    await loadCategories();
  } catch {
    showLogin();
  }
}

async function loadCategories() {
  const response = await apiRequest("/admin/categories");
  categoryOptions.innerHTML = "";

  for (const category of response.items ?? []) {
    const option = document.createElement("option");
    option.value = category.name;
    categoryOptions.appendChild(option);
  }
}

loginForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  loginError.hidden = true;

  const formData = new FormData(loginForm);
  const username = String(formData.get("username") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  try {
    const session = await apiRequest("/admin/login", {
      method: "POST",
      body: JSON.stringify({ username, password }),
    });

    storeSession(session);
    showAdmin(session);
    await loadCategories();
  } catch (error) {
    showLogin(error.message);
  }
});

logoutButton.addEventListener("click", () => {
  clearSession();
  showLogin();
});

tabButtons.forEach((tabButton) => {
  tabButton.addEventListener("click", () => {
    const tabName = tabButton.dataset.tab;

    tabButtons.forEach((button) => {
      button.classList.toggle("is-active", button === tabButton);
    });

    tabPanels.forEach((panel) => {
      panel.classList.toggle("is-active", panel.id === `${tabName}-tab`);
      panel.hidden = panel.id !== `${tabName}-tab`;
    });
  });
});

addSignForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  addSignMessage.hidden = true;

  const formData = new FormData(addSignForm);
  const payload = {
    signId: String(formData.get("signId") ?? "").trim(),
    conceptId: String(formData.get("conceptId") ?? "").trim(),
    englishWord: String(formData.get("englishWord") ?? "").trim(),
    nepaliWord: String(formData.get("nepaliWord") ?? "").trim(),
    category: String(formData.get("category") ?? "").trim(),
    meaningEnglish: String(formData.get("meaningEnglish") ?? "").trim(),
    meaningNepali: String(formData.get("meaningNepali") ?? "").trim(),
    videoUrl: String(formData.get("videoUrl") ?? "").trim() || null,
    thumbnailUrl: String(formData.get("thumbnailUrl") ?? "").trim() || null,
  };

  if (!payload.conceptId) {
    delete payload.conceptId;
  }

  try {
    const response = await apiRequest("/admin/signs", {
      method: "POST",
      body: JSON.stringify(payload),
    });

    addSignMessage.hidden = false;
    addSignMessage.className = "status-message is-success";
    addSignMessage.textContent =
      response.outcome?.status === "inserted"
        ? `Saved sign "${response.outcome.signId}".`
        : `Sign "${response.outcome?.signId}" already exists.`;
    addSignForm.reset();
  } catch (error) {
    addSignMessage.hidden = false;
    addSignMessage.className = "status-message is-error";
    addSignMessage.textContent = error.message;
  }
});

bulkImportForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  bulkImportResult.hidden = true;

  const fileInput = document.getElementById("bulk-file-input");
  const selectedFile = fileInput.files?.[0];
  if (!selectedFile) {
    bulkImportResult.hidden = false;
    bulkImportResult.textContent = "Choose a CSV or JSON file first.";
    return;
  }

  const uploadData = new FormData();
  uploadData.append("file", selectedFile);

  try {
    const response = await apiRequest("/admin/signs/bulk", {
      method: "POST",
      body: uploadData,
    });

    const result = response.result;
    bulkImportResult.hidden = false;
    bulkImportResult.textContent = [
      `Inserted: ${result.inserted}`,
      `Skipped: ${result.skipped}`,
      `Failed: ${result.failed}`,
      "",
      ...(result.errors ?? []).map((entry) => `- ${entry}`),
    ].join("\n");
  } catch (error) {
    bulkImportResult.hidden = false;
    bulkImportResult.textContent = error.message;
  }
});

verifyExistingSession();
