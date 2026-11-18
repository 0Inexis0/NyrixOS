import importlib.machinery, importlib.util, io, json, tempfile, time, unittest
from pathlib import Path
from unittest.mock import patch
p=Path(__file__).resolve().parents[1]/'desktop/bin/nyrix-island-data'
l=importlib.machinery.SourceFileLoader('island',str(p));s=importlib.util.spec_from_loader(l.name,l);m=importlib.util.module_from_spec(s);l.exec_module(m)
class Island(unittest.TestCase):
    def test_unknown_is_not_zero(self):
        self.assertIsNone(m.window(None,time.time()+300))
        self.assertIsNone(m.window(40,time.time()-1))
        self.assertIsNone(m.window(float('nan'),time.time()+300))
        self.assertEqual(m.window(0,time.time()+300)['used'],0)
    def test_claude_import_discards_private_payload(self):
        raw={'session_id':'private','prompt':'secret','rate_limits':{'five_hour':{'used_percentage':25,'resets_at':time.time()+1000}}}
        with tempfile.TemporaryDirectory() as d, patch.object(m,'CACHE',Path(d)), patch.object(m.sys,'stdin',io.StringIO(json.dumps(raw))):
            m.import_claude();stored=(Path(d)/'claude.json').read_text()
            self.assertNotIn('private',stored);self.assertNotIn('secret',stored)
            self.assertEqual(json.loads(stored)['five_hour']['used'],25)
            self.assertIsNone(json.loads(stored)['seven_day'])
    def test_weather_offline_keeps_timestamp(self):
        with tempfile.TemporaryDirectory() as d, patch.object(m,'CONFIG',Path(d)/'config'), patch.object(m,'CACHE',Path(d)/'cache'):
            loc={'latitude':50,'longitude':7,'name':'Test'}
            m.save(m.CONFIG/'weather-location.json',loc)
            before=time.time()-1000;m.save(m.CACHE/'weather.json',{'location':loc,'fetchedAt':before,'current':{'temperature_2m':10}})
            with patch.object(m,'fetch',side_effect=OSError('offline')):
                result=m.weather();self.assertTrue(result['stale']);self.assertEqual(result['fetchedAt'],before)
    def test_new_location_does_not_show_previous_weather(self):
        with tempfile.TemporaryDirectory() as d, patch.object(m,'CONFIG',Path(d)/'config'), patch.object(m,'CACHE',Path(d)/'cache'):
            m.save(m.CONFIG/'weather-location.json',{'name':'New','latitude':50,'longitude':7})
            m.save(m.CACHE/'weather.json',{'location':{'name':'Old'},'fetchedAt':time.time()})
            with patch.object(m,'fetch',side_effect=OSError('offline')):
                with self.assertRaises(OSError):m.weather()
if __name__=='__main__':unittest.main()
