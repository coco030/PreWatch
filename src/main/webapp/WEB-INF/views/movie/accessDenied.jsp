<%--
    파일명: accessDenied.jsp
    설명:
        이 JSP 파일은 사용자에게 접근 권한이 없음을 알리는 페이지입니다. 주로 특정 기능(예: 관리자 기능)에 대한 비인가 접근이 시도되었을 때 `movieController.java`와 같은 컨트롤러에서 `redirect:/accessDenied`와 같이 리다이렉트되어 사용자에게 표시됩니다.

    목적:
        - 사용자에게 권한 부족으로 인해 요청된 페이지에 접근할 수 없음을 전달.

--%>
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
    <%-- 푸터 삽입 위치: body 안쪽 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>