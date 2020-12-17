import {
  Component as $,
  render,
  html,
  useState,
  useRef,
  useEffect,
} from "//unpkg.com/uland?module";
import {
  Grid,
  html as gridHtml,
} from "https://unpkg.com/gridjs/dist/gridjs.production.es.min.js";

const useFetch = (url) => {
  const [data, setData] = useState({ state: "idle", data: null });
  useEffect(() => {
    const ac = new AbortController();
    const fetchData = () => {
      setData({ state: "loading", data: null });
      fetch(url, { signal: ac.signal })
        .then(async (r) => setData({ state: "loaded", data: await r.json() }))
        .catch((e) => setData({ state: "failed", data: e }));
    };
    fetchData();
    return () => {
      ac.abort();
      setData({ state: "failed", data: null });
    };
  }, [url]);
  return data;
};

const Grd = $((data = {}) => {
  const [props] = useState(data);
  const wrapper = useRef();
  const instance = useRef();
  useEffect(() => {
    instance.current = new Grid(props);
    instance.current.render(wrapper.current);
  }, []);
  useEffect(() => {
    instance.current.updateConfig(props).forceRender();
  }, [props]);

  return html`<div ref=${wrapper}></div>`;
});

// unsolved problems:
// The code is written fairly generically and dynamically to handle arbitrary
// keys, values, etc.
// But the "pruning" and deduplicating logic is fairly specific to the actual
// data and that is not implemented in a generic way. I'm not yet sure how best
// to represent that.

function formatData(data) {
  if (!Array.isArray(data) || !data.length) throw new Error("not an array");

  const has = (props) => (o) => props.every((p) => p in o);
  const props = {
    method: has(["status", "method", "specification", "loc"]),
    property: has(["status", "term", "loc"]),
  };
  if (!data.every((o) => "type" in o && props[o.type](o)))
    throw new Error("Not right shape");

  const items = data.reduce(
    (a, c) => ((a[c.type] = [...(a[c.type] || []), c]), a),
    {}
  );

  if (!Object.values(items).every((i) => !!i.length))
    throw new Error("wrong shape");
  return items;
}

const mkGridProps = (v) => ({
  columns: Object.keys(v[0]).map((x) =>
    x === "type" ? { name: x, hidden: true } : x
  ),
  search: true,
  sort: true,
  fixedHeader: true,
  data: v.map((vv) =>
    Object.values(vv).map((x) =>
      x.includes("\n") ? gridHtml(`<pre>${x}</pre>`) : x
    )
  ),
});

const dedupe = (data, key) => {
  const seen = new Set();
  const values = [];
  data.forEach((d) => !seen.has(d[key]) && seen.add(d[key]) && values.push(d));
  return values;
};

const distincts = (data, key) =>
  data.reduce((a, c) => ((a[c[key]] = (a[c[key]] || 0) + 1), a), {});

const Summary = (
  props = [{}],
  omittedSections = ["loc"],
  omittedFields = ["_title"]
) =>
  Object.keys(props[0])
    .filter((k) => !omittedSections.includes(k))
    .map((k) => ({ ...distincts(props, k), _title: k }))
    .map((o) => {
      return html`
        <details open class="py-5">
          <summary class="text-lg leading-6 font-medium text-gray-900">
            ${o._title}
          </summary>
          <ul class="grid af gap-2">
            ${Object.entries(o)
              .filter(([k, _]) => !omittedFields.includes(k))
              .map(
                ([k, v]) => html`<li
                  class="bg-white px-4 py-5 shadow-sm border-gray-100 text-sm flex justify-between"
                >
                  <span class="font-medium text-gray-500">Total ${k}</span>
                  <span class="text-gray-900 ml-2">${v}</span>
                </li>`
              )}
          </ul>
        </details>
      `;
    });

const uiSelector = ({ data, state }) =>
  ({
    idle: html`<p>Loading</p>`,
    loading: html`<p>Loading</p>`,
    loaded:
      !!data &&
      Object.entries(formatData(data)).map(
        ([k, v]) =>
          html`<section>
              ${Summary(v, ["loc", "type", "term"])}
              <div class="divide-y-5"><hr /></div>
              ${Grd(mkGridProps(dedupe(v, k === "method" ? k : "term")))}
            </section>
            <div class="border"></div>`
      ),
    failed: html`<p>Fetching the data failed</p>`,
  }[state]);

const Body = () =>
  html`<div class="space-y-24">${uiSelector(useFetch("./output.json"))}</div>`;

export async function main() {
  return render(document.getElementById("summaries"), $(Body));
}
