<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% System.out.println("로그인 페이지 뷰 진입"); %> 

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
</head>
<body class="bg-light">

<div class="container">
    <div class="row justify-content-center align-items-center min-vh-100">
        <div class="col-md-6 col-lg-5 col-xl-4">
            
            <div class="card shadow-sm">
                <div class="card-body p-4 p-md-5">
                    <h2 class="card-title text-center fw-bold mb-4">로그인</h2>

                    <%-- 로그인 실패 시 에러 메시지 표시 --%>
                    <%-- Spring Security는 실패 시 /login?error 로 리다이렉트 할 수 있습니다. --%>
                    <c:if test="${not empty param.error or not empty errorMessage}">
                        <div class="alert alert-danger" role="alert">
                            아이디 또는 비밀번호가 올바르지 않습니다.
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/auth/login" method="post">
                        <div class="mb-3">
                            <label for="id" class="form-label">아이디</label>
                            <input type="text" class="form-control" id="id" name="id" required>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">비밀번호</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" name="remember-me" id="rememberMe">
                            <label class="form-check-label" for="rememberMe">
                                로그인 상태 유지
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2">로그인</button>
                    </form>

                    <hr class="my-4">

                    <div class="text-center">
                        <p class="mb-0">아직 회원이 아니신가요? 
                            <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
                        </p>
                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</body>
</html>