<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<% System.out.println("tagForm 진입"); %>

<!-- 영화 ID -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="memberId" value="${loginMember.id}" />
</c:if>

<!-- 태그 표시 영역 -->
<h6 class="mb-2 fw-bold"><i class="fas fa-tags text-info me-1"></i>태그</h6>
<div id="tag-section" class="my-4">
    <c:if test="${not empty loginMember}">
        <p style="color: gray; font-size: 0.95em; margin-bottom: 6px;">
            <c:choose>
                <c:when test="${not empty myReview and not empty myReview.tags}">
                    <span id="tagList">#${fn:replace(myReview.tags, ',', ' #')}</span>
                </c:when>
                <c:otherwise>
                <!--    <span id="tagList">아직 태그를 달지 않으셨어요.</span> -->
                </c:otherwise>
            </c:choose>
        </p>
    </c:if>

    <!-- 태그 입력창 -->
    <div class="d-flex flex-wrap align-items-center gap-2">
        <input type="text"
               id="tagInput"
               name="tag"
               class="form-control border border-secondary-subtle rounded-pill px-3 py-1"
               placeholder="예: 절단, 잔인함"
               style="min-width: 150px; max-width: 100%; width: auto;" />
    </div>

    <!-- 태그 전체 삭제 버튼 -->
    <div class="mt-2">
        <button type="button"
                class="btn btn-outline-danger btn-sm"
                onclick="deleteAllTags()">
            전체 태그 삭제
        </button>
    </div>
</div>

<!-- JS (입력 및 삭제 Ajax 처리) -->
<script>
(function () {
    if (typeof $ === 'undefined') {
        console.error("jQuery 미탑재 - 태그 입력 불가");
        return;
    }

    const $tagInput = $('#tagInput');

    // 가짜 span으로 글자 길이 측정
    const $mirror = $('<span></span>').css({
        position: 'absolute',
        top: '-9999px',
        left: '-9999px',
        visibility: 'hidden',
        whiteSpace: 'pre',
        fontSize: $tagInput.css('font-size'),
        fontFamily: $tagInput.css('font-family'),
        fontWeight: $tagInput.css('font-weight'),
        letterSpacing: $tagInput.css('letter-spacing')
    }).appendTo(document.body);

    function updateInputWidth() {
        const value = $tagInput.val() || $tagInput.attr('placeholder') || '';
        $mirror.text(value);
        const newWidth = $mirror.width() + 30;
        $tagInput.css('width', newWidth + 'px');
    }

    updateInputWidth();
    $tagInput.on('input', updateInputWidth);

    $tagInput.on('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const movieId = $('#movieId').val();
            const tag = $tagInput.val().trim();
            if (!tag) {
                alert("태그를 입력하세요.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "${pageContext.request.contextPath}/review/saveTag",
                data: { movieId: movieId, tag: tag },
                success: function (response) {
                    if (response.success) {
                        alert("태그 저장됨: " + tag);
                        $tagInput.val("");
                        updateInputWidth();

                        if (response.updatedTags) {
                            const tags = response.updatedTags.split(',').map(t => '#' + t.trim()).join(' ');
                            $('#tagList').text(tags);
                        }
                    } else {
                        alert("실패: " + (response.message || '알 수 없는 오류'));
                    }
                },
                error: function (xhr) {
                    alert("태그 저장 중 오류: " + xhr.status);
                }
            });
        }
    });
})(); // ← 기존 함수 닫힘 위치

// 👇 여기부터 전체 삭제용 함수
function deleteAllTags() {
    const movieId = $('#movieId').val();

    if (!confirm("정말 모든 태그를 삭제하시겠습니까?")) return;

    $.ajax({
        type: "POST",
        url: "${pageContext.request.contextPath}/review/deleteAllTags",
        data: { movieId: movieId },
        success: function (response) {
            if (response.success) {
                $('#tagList').text('');
                alert("태그가 모두 삭제되었습니다.");
            } else {
                alert("삭제 실패: " + (response.message || '알 수 없는 오류'));
            }
        },
        error: function (xhr) {
            alert("요청 오류: " + xhr.status);
        }
    });
}
</script>
