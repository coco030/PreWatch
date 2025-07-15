<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>접근 권한 없음</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        h1 { color: #cc0000; }
        p { font-size: 1.2em; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>접근 권한 없음</h1>
    <p>이 페이지에 접근할 권한이 없습니다.</p>
    <p>로그인 상태를 확인하거나, 관리자에게 문의해주세요.</p>
    <p><a href="${pageContext.request.contextPath}/">홈으로 돌아가기</a></p>
</body>
</html>