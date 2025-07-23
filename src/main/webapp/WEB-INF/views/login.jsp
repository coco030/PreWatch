<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% System.out.println("로그인 페이지 뷰 진입"); %> 
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<div class="d-flex justify-content-center align-items-center vh-100 bg-white">
  <form class="w-100" style="max-width: 360px;" action="${pageContext.request.contextPath}/auth/login" method="post">
    <h2 class="text-center mb-4">로그인</h2>

    <div class="mb-3">
      <label for="id" class="form-label">아이디</label>
      <input type="text" class="form-control" id="id" name="id" required>
    </div>

    <div class="mb-3">
      <label for="password" class="form-label">비밀번호</label>
      <input type="password" class="form-control" id="password" name="password" required>
    </div>

    <button type="submit" class="btn btn-primary w-100">로그인</button>

    <p class="mt-3 text-center">
      아직 회원이 아니신가요? <a href="${pageContext.request.contextPath}/member/join">회원가입</a>
    </p>
  </form>
</div>
</body>
</html>