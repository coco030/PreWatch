<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>전체 영화 주의 요소 관리</title>
    <style>
        body { font-family: sans-serif; }
        table { border-collapse: collapse; width: 100%; font-size: 12px; table-layout: fixed; }
        th, td { border: 1px solid #ddd; padding: 6px; text-align: center; }
        th { background-color: #f2f2f2; position: sticky; top: 0; z-index: 10; }
        .movie-title { 
            text-align: left; 
            width: 200px; 
            white-space: nowrap; 
            overflow: hidden; 
            text-overflow: ellipsis;
            position: sticky;
            left: 0;
            background-color: #f8f9fa;
            z-index: 5;
        }
        form { margin-top: 20px; }
        button { padding: 10px 20px; font-size: 16px; cursor: pointer; }
    </style>
</head>
<body>
    <h1>전체 영화 주의 요소 관리</h1>
    <p>이 페이지에서 모든 영화의 주의 요소를 한 번에 설정하고 저장할 수 있습니다.</p>

    <c:if test="${param.update == 'success'}">
        <p style="color: green; font-weight: bold;">성공적으로 저장되었습니다!</p>
    </c:if>

    <form action="<c:url value='/admin/warnings/all'/>" method="post">
        <table>
            <thead>
                <tr>
                    <%-- 왼쪽 상단 고정 컬럼 --%>
                    <th class="movie-title">영화 제목</th> 
                    
                    <%-- 주의 요소 컬럼 헤더 (가로 스크롤) --%>
                    <c:forEach items="${allTagsGrouped}" var="categoryEntry">
                        <c:forEach items="${categoryEntry.value}" var="tag">
                            <%-- 툴팁으로 전체 문장 보여주기 --%>
                            <th title="${tag.sentence}"> 
                                ${categoryEntry.key}
                                <br/>
                                (${fn:substring(tag.sentence, 0, 5)}...)
                            </th>
                        </c:forEach>
                    </c:forEach>
                </tr>
            </thead>
            <tbody>
                <%-- 각 영화를 한 행으로 표시 --%>
                <c:forEach items="${allMovies}" var="movie">
                    <tr>
                        <%-- 영화 제목 (세로 스크롤 시 고정) --%>
                        <td class="movie-title" title="${movie.title}">
                            <a href="<c:url value='/admin/warnings/${movie.id}'/>" target="_blank">
                                ${movie.title}
                            </a>
                        </td>

                        <%-- 각 주의 요소에 해당하는 체크박스를 동적으로 생성 --%>
                        <c:forEach items="${allTagsGrouped}" var="categoryEntry">
                            <c:forEach items="${categoryEntry.value}" var="tag">
                                <td>
                                    <%-- 체크박스의 name을 "tags_{영화ID}" 형태로 만들어 서버에서 구분 --%>
                                    <input type="checkbox" name="tags_${movie.id}" value="${tag.id}"
                                        
                                        <%-- Controller에서 넘겨준 Map에서 현재 영화의 선택된 태그 목록에 이 태그 ID가 있는지 확인 --%>
                                        <c:if test="${movieToSelectedTagsMap[movie.id].contains(tag.id)}">
                                            checked
                                        </c:if>
                                    >
                                </td>
                            </c:forEach>
                        </c:forEach>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <br>
        <button type="submit">전체 변경사항 저장</button>
    </form>
</body>
</html>