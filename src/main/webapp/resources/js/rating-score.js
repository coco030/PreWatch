(function (window) {
    function initRatingForm(config) {
        const container = document.getElementById(config.containerId);
        if (!container) {
            return;
        }

        const movieId = config.movieId;
        const halves = container.querySelectorAll(".half");
        const icons = container.querySelectorAll(".rating-icon-fill");
        const label = document.getElementById(config.labelId);
        const guide = document.getElementById(config.guideId);
        const messages = config.messages || [];
        const emptyLabel = config.emptyLabel || "";
        const isTouchDevice = "ontouchstart" in window || navigator.maxTouchPoints > 0;
        let currentScore = Number(config.initialScore) || 0;
        let touchPreviewScore = 0;
        let suppressNextClick = false;

        renderCurrentScore();

        halves.forEach(half => {
            half.addEventListener("mouseover", function () {
                if (!isTouchDevice) {
                    previewScore(this);
                }
            });

            half.addEventListener("touchstart", function () {
                touchPreviewScore = getScore(this);
                previewScore(this);
            }, { passive: true });

            half.addEventListener("touchmove", function (event) {
                const touchedHalf = findHalfFromTouch(event);
                if (touchedHalf) {
                    touchPreviewScore = getScore(touchedHalf);
                    previewScore(touchedHalf);
                }
            }, { passive: true });

            half.addEventListener("touchend", function (event) {
                if (touchPreviewScore <= 0) {
                    return;
                }

                event.preventDefault();
                selectScore(touchPreviewScore);
                touchPreviewScore = 0;
                suppressNextClick = true;
                window.setTimeout(function () {
                    suppressNextClick = false;
                }, 400);
            });

            half.addEventListener("click", function () {
                if (suppressNextClick) {
                    return;
                }

                selectScore(getScore(this));
            });
        });

        container.addEventListener("mouseleave", function () {
            if (!isTouchDevice) {
                renderCurrentScore();
            }
        });

        container.addEventListener("touchcancel", function () {
            touchPreviewScore = 0;
            renderCurrentScore();
        });

        function findHalfFromTouch(event) {
            const touch = event.touches && event.touches[0];
            if (!touch) {
                return null;
            }

            const touchedElement = document.elementFromPoint(touch.clientX, touch.clientY);
            const touchedHalf = touchedElement ? touchedElement.closest(".half") : null;
            return touchedHalf && container.contains(touchedHalf) ? touchedHalf : null;
        }

        function getScore(scoreTarget) {
            return parseInt(scoreTarget.dataset.value, 10) || 0;
        }

        function previewScore(scoreTarget) {
            const previewScore = getScore(scoreTarget);
            updateIcons(previewScore);
            setLabel(previewScore + " / 10");
            showGuide(previewScore);
        }

        function selectScore(score) {
            if (!config.isLoggedIn) {
                openLoginPrompt("평가를 남기려면 로그인이 필요해요.");
                renderCurrentScore();
                return;
            }

            currentScore = score;
            updateIcons(score);
            setLabel(score + " / 10");
            showGuide(score);
            saveScore(score);
        }

        function openLoginPrompt(message) {
            if (window.openPrewatchLoginModal) {
                window.openPrewatchLoginModal({ message: message });
                return;
            }

            const modalElement = document.getElementById("loginModal");
            if (!modalElement || !window.bootstrap || !window.bootstrap.Modal) {
                return;
            }

            const messageTag = modalElement.querySelector(".login-message");
            if (messageTag) {
                messageTag.textContent = message;
                messageTag.style.display = "block";
            }

            window.bootstrap.Modal.getOrCreateInstance(modalElement).show();
        }

        function renderCurrentScore() {
            updateIcons(currentScore);
            setLabel(currentScore > 0 ? currentScore + " / 10" : emptyLabel);
            hideGuide();
        }

        function updateIcons(score) {
            icons.forEach((icon, index) => {
                const fullValue = (index + 1) * 2;
                const halfValue = fullValue - 1;
                let width = "0%";

                if (score >= fullValue) {
                    width = "100%";
                } else if (score === halfValue) {
                    width = "50%";
                }

                icon.style.width = width;
            });
        }

        function setLabel(text) {
            if (label) {
                label.textContent = text;
            }
        }

        function showGuide(score) {
            if (!guide) {
                return;
            }

            const message = getGuideText(score);
            if (!message) {
                hideGuide();
                return;
            }

            guide.textContent = message;
            guide.classList.add("is-visible");
        }

        function hideGuide() {
            if (!guide) {
                return;
            }

            guide.textContent = "";
            guide.classList.remove("is-visible");
        }

        function getGuideText(score) {
            const guideMessage = messages.find(item => score <= item.max);
            return guideMessage ? guideMessage.text : "";
        }

        function saveScore(score) {
            const formData = new URLSearchParams();
            formData.append("movieId", movieId);
            formData.append(config.scoreParam, score);

            fetch(config.contextPath + config.savePath, {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error("서버 응답 오류");
                }
                return response.json();
            })
            .then(data => {
                if (config.successLog) {
                    console.log(config.successLog, data);
                }
            })
            .catch(error => {
                console.error(config.errorLog || "점수 저장 실패:", error);
                if (config.errorMessage) {
                    alert(config.errorMessage);
                }
            });
        }
    }

    window.PrewatchRatingForm = {
        init: initRatingForm
    };
})(window);
