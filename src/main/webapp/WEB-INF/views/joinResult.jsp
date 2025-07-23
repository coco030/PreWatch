<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% System.out.println("회원가입 결과 뷰 진입"); %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>가입 완료</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-white">

<div class="d-flex justify-content-center align-items-center vh-100">
    <div class="text-center">
        <h2 class="mb-4">🎉 가입을 축하드립니다!</h2>

        <div class="d-grid gap-2">
            <a href="${pageContext.request.contextPath}" class="btn btn-outline-secondary">홈으로 가기</a>
            <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline-primary">로그인하기</a>
        </div>
    </div>
</div>

</body>
</html>
