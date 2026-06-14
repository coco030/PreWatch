(function () {
    function ready(callback) {
        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", callback);
            return;
        }
        callback();
    }

    function toArray(list) {
        return Array.prototype.slice.call(list);
    }

    function findRows(panel, apiId) {
        return toArray(panel.querySelectorAll("[data-register-row]")).filter(function (row) {
            return row.getAttribute("data-api-id") === apiId;
        });
    }

    function showToast(toast, message, isError) {
        if (!toast) {
            return;
        }
        toast.textContent = message;
        toast.classList.toggle("is-error", Boolean(isError));
        toast.classList.add("is-visible");
        clearTimeout(toast.hideTimer);
        toast.hideTimer = setTimeout(function () {
            toast.classList.remove("is-visible");
        }, 2600);
    }

    function markRegistered(panel, apiId) {
        findRows(panel, apiId).forEach(function (row) {
            row.classList.add("is-registered");

            var checkbox = row.querySelector(".js-register-check");
            if (checkbox) {
                checkbox.checked = false;
                checkbox.removeAttribute("data-busy-disabled");
                checkbox.disabled = true;
            }

            var button = row.querySelector(".js-register-one");
            if (button) {
                button.disabled = true;
                button.textContent = "등록 완료";
                button.classList.add("is-complete");
            }

            var status = row.querySelector("[data-register-status]");
            if (status) {
                status.textContent = "등록 완료";
            }
        });
    }

    function updateSelectAll(panel) {
        var selectAll = panel.querySelector("[data-select-all]");
        var checkboxes = toArray(panel.querySelectorAll(".js-register-check:not(:disabled)"));
        var checked = checkboxes.filter(function (checkbox) {
            return checkbox.checked;
        });

        if (selectAll) {
            selectAll.checked = checkboxes.length > 0 && checked.length === checkboxes.length;
            selectAll.indeterminate = checked.length > 0 && checked.length < checkboxes.length;
        }

        var countText = panel.querySelector("[data-register-count]");
        if (countText) {
            countText.textContent = checked.length > 0 ? checked.length + "개 선택됨" : "선택된 영화 없음";
        }
    }

    function setBusy(panel, busy) {
        toArray(panel.querySelectorAll("button")).forEach(function (button) {
            if (!button.classList.contains("is-complete")) {
                button.disabled = busy;
            }
        });

        if (busy) {
            toArray(panel.querySelectorAll(".js-register-check:not(:disabled)")).forEach(function (checkbox) {
                checkbox.setAttribute("data-busy-disabled", "true");
                checkbox.disabled = true;
            });
        } else {
            toArray(panel.querySelectorAll(".js-register-check[data-busy-disabled='true']")).forEach(function (checkbox) {
                checkbox.disabled = false;
                checkbox.removeAttribute("data-busy-disabled");
            });
        }

        panel.classList.toggle("is-registering", busy);
    }

    function requestRegister(importUrl, apiId) {
        var body = new URLSearchParams();
        body.append("imdbId", apiId);

        return fetch(importUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                "X-Requested-With": "XMLHttpRequest"
            },
            body: body.toString()
        }).then(function (response) {
            return response.json().then(function (data) {
                data.ok = response.ok;
                return data;
            });
        });
    }

    function registerMany(panel, apiIds) {
        var importUrl = panel.getAttribute("data-import-url");
        var toast = document.querySelector("[data-register-toast]");
        var progress = panel.querySelector("[data-register-progress]");
        var targets = apiIds.filter(function (apiId, index) {
            return apiId && apiIds.indexOf(apiId) === index;
        });

        if (targets.length === 0) {
            showToast(toast, "등록할 영화를 선택해주세요.", true);
            return Promise.resolve();
        }

        setBusy(panel, true);

        var created = 0;
        var exists = 0;
        var failed = 0;
        var chain = Promise.resolve();

        targets.forEach(function (apiId, index) {
            chain = chain.then(function () {
                if (progress) {
                    progress.textContent = (index + 1) + " / " + targets.length + " 등록 중";
                }

                return requestRegister(importUrl, apiId)
                    .then(function (result) {
                        if (result.ok && (result.status === "created" || result.status === "exists")) {
                            markRegistered(panel, apiId);
                            if (result.status === "created") {
                                created++;
                            } else {
                                exists++;
                            }
                            return;
                        }
                        failed++;
                    })
                    .catch(function () {
                        failed++;
                    });
            });
        });

        return chain.then(function () {
            if (progress) {
                progress.textContent = "";
            }
            updateSelectAll(panel);

            var parts = [];
            if (created > 0) parts.push(created + "개 등록 완료");
            if (exists > 0) parts.push(exists + "개 이미 등록됨");
            if (failed > 0) parts.push(failed + "개 실패");
            showToast(toast, parts.join(", ") || "처리할 영화가 없습니다.", failed > 0);
        }).finally(function () {
            setBusy(panel, false);
        });
    }

    function initPanel(panel) {
        var selectAll = panel.querySelector("[data-select-all]");
        var selectedButton = panel.querySelector("[data-register-selected]");
        var allButton = panel.querySelector("[data-register-all]");

        if (selectAll) {
            selectAll.addEventListener("change", function () {
                toArray(panel.querySelectorAll(".js-register-check:not(:disabled)")).forEach(function (checkbox) {
                    checkbox.checked = selectAll.checked;
                });
                updateSelectAll(panel);
            });
        }

        toArray(panel.querySelectorAll(".js-register-check")).forEach(function (checkbox) {
            checkbox.addEventListener("change", function () {
                updateSelectAll(panel);
            });
        });

        toArray(panel.querySelectorAll(".js-register-form")).forEach(function (form) {
            form.addEventListener("submit", function (event) {
                event.preventDefault();
                registerMany(panel, [form.getAttribute("data-api-id")]);
            });
        });

        if (selectedButton) {
            selectedButton.addEventListener("click", function () {
                var apiIds = toArray(panel.querySelectorAll(".js-register-check:checked:not(:disabled)")).map(function (checkbox) {
                    return checkbox.value;
                });
                registerMany(panel, apiIds);
            });
        }

        if (allButton) {
            allButton.addEventListener("click", function () {
                var checkboxes = toArray(panel.querySelectorAll(".js-register-check:not(:disabled)"));
                checkboxes.forEach(function (checkbox) {
                    checkbox.checked = true;
                });
                updateSelectAll(panel);
                registerMany(panel, checkboxes.map(function (checkbox) {
                    return checkbox.value;
                }));
            });
        }

        updateSelectAll(panel);
    }

    ready(function () {
        toArray(document.querySelectorAll("[data-register-panel]")).forEach(initPanel);
    });
})();
