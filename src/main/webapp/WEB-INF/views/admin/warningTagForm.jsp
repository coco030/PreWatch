<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>주의 요소 관리</title>
</head><body>
    <h2>영화 ID: ${movieId} - 주의 요소 관리</h2>
    <p>사용자에게 노출할 주의 요소를 모두 선택하고 저장하세요.</p>

    <form action="/admin/movies/${movieId}/warnings" method="post">
        <c:forEach items="${allTagsGrouped}" var="entry">
            <fieldset style="margin-bottom: 20px;">
                <legend><b>${entry.key}</b></legend>
                <c:forEach items="${entry.value}" var="tag">
                    <div>
                        <input type="checkbox" name="tagIds" value="${tag.id}" id="tag_${tag.id}"
                               <c:if test="${selectedTagIds.contains(tag.id)}">checked</c:if>
                        >
                        <label for="tag_${tag.id}">${tag.sentence}</label>
                    </div>
                </c:forEach>
            </fieldset>
        </c:forEach>
        <button type="submit">저장하기</button>
    </form>
</body>
</html>