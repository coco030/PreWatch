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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-white">

<div class="d-flex justify-content-center align-items-center vh-100">
    <div class="w-100" style="max-width: 400px;">
        <h2 class="text-center mb-4">회원가입</h2>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/member/join" method="post">
            <div class="mb-3">
                <label for="id" class="form-label">아이디</label>
                <input type="text" class="form-control" id="id" name="id" required>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">비밀번호</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>

            <button type="submit" class="btn btn-success w-100">가입하기</button>
        </form>
    </div>
</div>

</body>
</html>