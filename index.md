---
layout: cv
title: Michelle Lynn Gill's CV
---
# {{ site.data.bio.name }}
{{ site.data.bio.title }}

<div id="webaddress">
{% if site.data.socials.email %}<a href="mailto:{{ site.data.socials.email }}">{{ site.data.socials.email }}</a> | {% endif %}
<a href="https://github.com/{{ site.data.socials.github_username }}">GitHub</a> |
<a href="https://linkedin.com/in/{{ site.data.socials.linkedin_username }}">LinkedIn</a> |
<a href="https://michellelynngill.com">Personal Website</a>
</div>

## Currently

{{ site.data.bio.bio }}

## Education
{% assign education = site.data.cv | where: "title", "Education" | first %}
{% for edu in education.contents %}
`{{ edu.year }}`
__{{ edu.title }}__
<br>{{ edu.institution }}, {{ edu.location }}
{% if edu.description %}
{% for desc in edu.description %}
- {{ desc }}
{% endfor %}
{% endif %}

{% endfor %}

## Experience
{% assign experience = site.data.cv | where: "title", "Selected Experience" | first %}
{% for exp in experience.contents %}
`{{ exp.year }}`
__{{ exp.title }}__, {{ exp.institution }}
{% if exp.description %}
{% for desc in exp.description %}
- {{ desc }}
{% endfor %}
{% endif %}

{% endfor %}

## Publications

{% bibliography %}

### Patents
{% for year_group in site.data.patents %}
{% for patent in year_group.entries %}
`{{ year_group.year }}`
{{ patent.title }}
- {{ patent.authors }}
- {{ patent.details }}

{% endfor %}
{% endfor %}

## Presentations
{% for year_group in site.data.presentations %}
{% for pres in year_group.entries %}
`{{ year_group.year }}`
__{{ pres.title }}__{% if pres.venue %}, *{{ pres.venue }}*{% endif %}
{% if pres.authors and pres.authors != "" %}- {{ pres.authors }}
{% endif %}{% if pres.details and pres.details != "" %}- {{ pres.details }}
{% endif %}{% if pres.links.size > 0 %}- {% if pres.links.slides %}<a href="{{ pres.links.slides }}" class="pres-slides">Slides</a>{% endif %}{% if pres.links.video %}{% if pres.links.slides %} · {% endif %}<a href="{{ pres.links.video }}" class="pres-video">Video</a>{% endif %}{% if pres.links.abstract %}{% if pres.links.slides or pres.links.video %} · {% endif %}<a href="{{ pres.links.abstract }}" class="pres-abstract">Abstract</a>{% endif %}{% if pres.links.program %}{% if pres.links.slides or pres.links.video or pres.links.abstract %} · {% endif %}<a href="{{ pres.links.program }}" class="pres-program">Program</a>{% endif %}{% if pres.links.code %}{% if pres.links.slides or pres.links.video or pres.links.abstract or pres.links.program %} · {% endif %}<a href="{{ pres.links.code }}" class="pres-code">Code</a>{% endif %}{% if pres.links.thesis %}{% if pres.links.slides or pres.links.video or pres.links.abstract or pres.links.program or pres.links.code %} · {% endif %}<a href="{{ pres.links.thesis }}" class="pres-thesis">Thesis</a>{% endif %}
{% endif %}
{% endfor %}
{% endfor %}

## Awards
{% assign awards = site.data.cv | where: "title", "Honors and Awards" | first %}
{% for award in awards.contents %}
`{{ award.year }}`
{% for item in award.items %}
{{ item }}
{% endfor %}

{% endfor %}

## Service
{% assign service = site.data.cv | where: "title", "Service" | first %}
{% for svc in service.contents %}
`{{ svc.year }}`
__{{ svc.title }}__, {{ svc.institution }}{% if svc.location %}, {{ svc.location }}{% endif %}
{% if svc.description %}
{% for desc in svc.description %}
- {{ desc }}
{% endfor %}
{% endif %}

{% endfor %}
