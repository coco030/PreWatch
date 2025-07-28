<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인 성공</title>
</head>
<body>
<script>
  if (window !== window.parent) {
    // iframe 안에서 로그인한 경우 → 부모창 전체 새로고침
    window.parent.location.reload();
  } else {
    // 일반 브라우저에서 접근한 경우 → 메인으로 이동
    window.location.href = "<c:url value='/'/>";
  }
</script>
</body>
</html>
