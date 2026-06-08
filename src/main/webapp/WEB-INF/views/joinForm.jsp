<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% System.out.println("joinForm/회원가입 폼 뷰 진입"); %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- Bootstrap CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
    <style>
        html.embedded-auth-root body,
        body.embedded-auth-page {
            overflow-x: hidden;
        }

        html.embedded-auth-root body .embedded-auth-hide,
        body.embedded-auth-page .embedded-auth-hide {
            display: none !important;
        }
    </style>
    <script>
        if (window !== window.parent) {
            document.documentElement.classList.add("embedded-auth-root");
            document.addEventListener("DOMContentLoaded", function () {
                document.body.classList.add("embedded-auth-page");
            });
        }
    </script>
</head>
<body class="bg-light">

<div class="container">
    <div class="row justify-content-center align-items-center min-vh-100">
        <div class="col-md-6 col-lg-5 col-xl-4">

            <div class="card shadow-sm">
                <div class="card-body p-4 p-md-5">
                    <h2 class="card-title text-center fw-bold mb-4">회원가입</h2>

                    <%-- 서버로부터 받은 에러 메시지 표시 --%>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" role="alert">
                            ${errorMessage}
                        </div>
                    </c:if>

                    <form id="joinForm" action="${pageContext.request.contextPath}/member/join" method="post">
                        <div class="mb-3">
                            <label for="id" class="form-label">아이디</label>
                            <input type="text" class="form-control" id="id" name="id" required>
                            <div id="idFeedback" class="form-text" aria-live="polite"></div>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">비밀번호</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>

                        <div class="mb-4">
                            <label for="confirmPassword" class="form-label">비밀번호 확인</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                            <div class="invalid-feedback">비밀번호가 일치하지 않습니다.</div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2">가입하기</button>
                    </form>

                    <hr class="my-4">

                    <div class="text-center">
                        <p class="mb-0">이미 계정이 있으신가요? 
                            <a href="${pageContext.request.contextPath}/auth/login">로그인</a>
                        </p>
                    </div>
                    
                    <div class="text-center mt-3 embedded-auth-hide">
					    <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary w-100 py-2" target="_top">
					        홈으로 돌아가기
					    </a>
					</div>

                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const joinForm = document.getElementById("joinForm");
    const idInput = document.getElementById("id");
    const idFeedback = document.getElementById("idFeedback");
    const password = document.getElementById("password");
    const confirmPassword = document.getElementById("confirmPassword");
    const checkIdUrl = "${pageContext.request.contextPath}/member/check-id";
    let idCheckTimer = null;
    let isIdAvailable = false;
    let lastCheckedId = "";

    function syncPasswordMatch() {
        if (!password || !confirmPassword) {
            return true;
        }

        const isMatched = confirmPassword.value === "" || password.value === confirmPassword.value;
        confirmPassword.classList.toggle("is-invalid", !isMatched);
        return isMatched;
    }

    function setIdFeedback(message, status) {
        if (!idInput || !idFeedback) {
            return;
        }

        idFeedback.textContent = message;
        idFeedback.className = "form-text";
        idInput.classList.remove("is-valid", "is-invalid");

        if (status === "success") {
            idFeedback.classList.add("text-success");
            idInput.classList.add("is-valid");
        } else if (status === "danger") {
            idFeedback.classList.add("text-danger");
            idInput.classList.add("is-invalid");
        } else if (status === "muted" && message) {
            idFeedback.classList.add("text-muted");
        }
    }

    async function checkIdAvailability() {
        if (!idInput) {
            return false;
        }

        const targetId = idInput.value.trim();
        isIdAvailable = false;
        lastCheckedId = "";

        if (targetId === "") {
            setIdFeedback("", "");
            return false;
        }

        setIdFeedback("아이디를 확인하고 있습니다.", "muted");

        try {
            const response = await fetch(checkIdUrl + "?id=" + encodeURIComponent(targetId), {
                headers: { "Accept": "application/json" }
            });

            if (!response.ok) {
                throw new Error("ID check failed");
            }

            const result = await response.json();
            if (idInput.value.trim() !== targetId) {
                return false;
            }

            lastCheckedId = targetId;
            isIdAvailable = Boolean(result.available);

            if (result.empty) {
                setIdFeedback("", "");
            } else if (isIdAvailable) {
                setIdFeedback("사용 가능한 아이디입니다.", "success");
            } else {
                setIdFeedback("이미 사용 중인 아이디입니다.", "danger");
            }

            return isIdAvailable;
        } catch (error) {
            if (idInput.value.trim() === targetId) {
                setIdFeedback("아이디 중복 확인을 다시 시도해주세요.", "danger");
            }

            return false;
        }
    }

    idInput?.addEventListener("input", function () {
        window.clearTimeout(idCheckTimer);
        isIdAvailable = false;
        lastCheckedId = "";

        if (idInput.value.trim() === "") {
            setIdFeedback("", "");
            return;
        }

        setIdFeedback("아이디를 확인하고 있습니다.", "muted");
        idCheckTimer = window.setTimeout(checkIdAvailability, 300);
    });

    password?.addEventListener("input", syncPasswordMatch);
    confirmPassword?.addEventListener("input", syncPasswordMatch);

    joinForm?.addEventListener("submit", function (event) {
        if (idInput) {
            const idValue = idInput.value.trim();
            if (idValue === "" || lastCheckedId !== idValue || !isIdAvailable) {
                event.preventDefault();
                if (idValue === "") {
                    setIdFeedback("아이디를 입력해주세요.", "danger");
                } else if (lastCheckedId !== idValue) {
                    setIdFeedback("아이디 중복 확인이 끝난 뒤 가입해주세요.", "muted");
                } else {
                    setIdFeedback("이미 사용 중인 아이디입니다.", "danger");
                }
                idInput.focus();
                return;
            }
        }

        if (!syncPasswordMatch()) {
            event.preventDefault();
            confirmPassword.focus();
        }
    });

    if (idInput?.value.trim() !== "") {
        checkIdAvailability();
    }
});
</script>
</body>
</html>
